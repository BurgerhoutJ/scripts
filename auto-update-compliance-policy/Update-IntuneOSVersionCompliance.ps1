#Requires -Modules Az.Accounts
<#
Azure Automation runbook (PowerShell 7.2) that keeps "OS Minimum version" on
Intune device compliance policies pinned to n-1 (current major - 1) and clears
"OS Maximum version", for iOS/iPadOS, macOS, Windows, and Android.

Version data source: https://endoflife.date/api/<product>.json (community
maintained, JSON, one consistent schema across all four platforms).

Safety model:
  - Writes only happen when both -Apply is passed AND the policy's platform is
    listed in the "IntuneOSVersion-AutoApplyPlatforms" Automation Variable.
    Everything else always runs as a dry run (logged, not written).
  - Policies whose ID is listed in "IntuneOSVersion-ExcludePolicyIds" are never
    touched.
  - A platform whose release data can't be fetched/parsed this run is skipped
    entirely rather than falling back to a guess.
#>

param(
    [string[]] $Platforms = @('ios', 'macos', 'windows', 'android'),
    [switch] $Apply,
    [int] $PatchLevelMonthsBack = 6
)

$ErrorActionPreference = 'Stop'

function Get-GraphToken {
    $tokenObj = Get-AzAccessToken -ResourceUrl 'https://graph.microsoft.com'
    if ($tokenObj.Token -is [System.Security.SecureString]) {
        return [System.Net.NetworkCredential]::new('', $tokenObj.Token).Password
    }
    return $tokenObj.Token
}

function Invoke-GraphGet {
    param([string] $Uri, [string] $Token)
    $items = @()
    $next = $Uri
    while ($next) {
        $resp = Invoke-RestMethod -Uri $next -Headers @{ Authorization = "Bearer $Token" } -Method Get
        $items += $resp.value
        $next = $resp.'@odata.nextLink'
    }
    return $items
}

function Get-OSReleaseCycles {
    param([string] $Product)
    $cycles = Invoke-RestMethod -Uri "https://endoflife.date/api/$Product.json" -Method Get
    $today = Get-Date
    # Drop anything not actually released yet (e.g. an announced-but-unshipped cycle).
    return $cycles | Where-Object { $_.releaseDate -and ([datetime]$_.releaseDate) -le $today }
}

function Get-NMinus1Baseline {
    param([string] $Product, [object[]] $Cycles)

    if ($Product -eq 'windows') {
        # Windows cycle IDs encode feature-update + channel (e.g. "11-25h2-e") and
        # don't sort cleanly; the actual OS build number in 'latest' does.
        $builds = $Cycles | Select-Object -ExpandProperty latest -Unique | Sort-Object { [version] $_ } -Descending
        if ($builds.Count -lt 2) { throw "Not enough Windows release history to determine n-1" }
        return $builds[1]
    }

    # ios/macos/android: 'cycle' is the major version number, but the numbering
    # scheme itself isn't guaranteed contiguous (Apple jumped 18 -> 26 in 2025),
    # so pick the second most recent release *positionally*, never by subtracting 1.
    $sorted = $Cycles | Where-Object { $_.cycle -match '^\d+$' } | Sort-Object { [int] $_.cycle } -Descending
    if ($sorted.Count -lt 2) { throw "Not enough $Product release history to determine n-1" }
    return "$($sorted[1].cycle).0"
}

$odataPlatformMap = @{
    '#microsoft.graph.iosCompliancePolicy'               = 'ios'
    '#microsoft.graph.macOSCompliancePolicy'              = 'macos'
    '#microsoft.graph.windows10CompliancePolicy'          = 'windows'
    '#microsoft.graph.androidCompliancePolicy'            = 'android'
    '#microsoft.graph.androidWorkProfileCompliancePolicy' = 'android'
    '#microsoft.graph.androidDeviceOwnerCompliancePolicy' = 'android'
}

Connect-AzAccount -Identity | Out-Null
$token = Get-GraphToken

$autoApplyPlatforms = @()
try {
    $raw = Get-AutomationVariable -Name 'IntuneOSVersion-AutoApplyPlatforms'
    if ($raw) { $autoApplyPlatforms = $raw -split ',' | ForEach-Object { $_.Trim().ToLower() } }
} catch {
    Write-Output "No 'IntuneOSVersion-AutoApplyPlatforms' variable found - every platform will run as dry run this pass."
}

$excludeIds = @()
try {
    $raw = Get-AutomationVariable -Name 'IntuneOSVersion-ExcludePolicyIds'
    if ($raw) { $excludeIds = $raw -split ',' | ForEach-Object { $_.Trim() } }
} catch {}

$baselines = @{}
foreach ($p in $Platforms) {
    try {
        $cycles = Get-OSReleaseCycles -Product $p
        $baselines[$p] = Get-NMinus1Baseline -Product $p -Cycles $cycles
        Write-Output "Baseline for '$p': osMinimumVersion = $($baselines[$p])"
    } catch {
        Write-Warning "Skipping '$p' this run - could not determine baseline: $($_.Exception.Message)"
    }
}

# --- Compliance Policies (osMinimumVersion / osMaximumVersion) ---

Write-Output "--- Compliance Policies ---"

$policies = Invoke-GraphGet -Token $token -Uri 'https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies?$top=200'

$changed = 0
$applied = 0

foreach ($policy in $policies) {
    $type = $policy.'@odata.type'
    if (-not $type -or -not $odataPlatformMap.ContainsKey($type)) { continue }

    $platform = $odataPlatformMap[$type]
    if ($platform -notin $Platforms) { continue }
    if (-not $baselines.ContainsKey($platform)) { continue }

    if ($policy.id -in $excludeIds) {
        Write-Output "Excluded: '$($policy.displayName)' ($($policy.id))"
        continue
    }

    $desiredMin = $baselines[$platform]
    $needsUpdate = ($policy.osMinimumVersion -ne $desiredMin) -or [bool]$policy.osMaximumVersion

    if (-not $needsUpdate) {
        Write-Output "OK (no change): '$($policy.displayName)' [$platform] already Min=$desiredMin Max=blank"
        continue
    }

    $changed++
    $willApply = $Apply -and ($platform -in $autoApplyPlatforms)
    $label = if ($willApply) { 'APPLYING' } else { 'DRY RUN' }

    Write-Output "$label '$($policy.displayName)' [$platform] ($($policy.id)): osMinimumVersion '$($policy.osMinimumVersion)' -> '$desiredMin', osMaximumVersion '$($policy.osMaximumVersion)' -> (blank)"

    if ($willApply) {
        $body = @{
            '@odata.type'     = $type
            osMinimumVersion  = $desiredMin
            osMaximumVersion  = $null
        } | ConvertTo-Json -Compress

        Invoke-RestMethod -Method Patch `
            -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies/$($policy.id)" `
            -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } `
            -Body $body | Out-Null
        $applied++
    }
}

Write-Output "Compliance policies: $($policies.Count) scanned, $changed needed changes, $applied written."

# --- App Protection Policies (conditional launch) ---

$appPlatforms = $Platforms | Where-Object { $_ -in @('ios', 'android') }

if ($appPlatforms.Count -gt 0) {
    Write-Output "`n--- App Protection Policies (conditional launch) ---"

    $minimumPatchVersion = (Get-Date).ToUniversalTime().AddMonths(-$PatchLevelMonthsBack).ToString('yyyy-MM-01')
    if ('android' -in $appPlatforms) {
        Write-Output "Android minimum patch level: $minimumPatchVersion ($PatchLevelMonthsBack months back)"
    }

    $appChanged = 0
    $appApplied = 0

    if ('ios' -in $appPlatforms -and $baselines.ContainsKey('ios')) {
        $iosApps = Invoke-GraphGet -Token $token -Uri 'https://graph.microsoft.com/v1.0/deviceAppManagement/iosManagedAppProtections?$top=200'
        foreach ($app in $iosApps) {
            if ($app.id -in $excludeIds) {
                Write-Output "Excluded APP: '$($app.displayName)' ($($app.id))"
                continue
            }
            $desiredMin = $baselines['ios']
            if ($app.minimumRequiredOsVersion -eq $desiredMin) {
                Write-Output "OK (no change) APP: '$($app.displayName)' [ios] minimumRequiredOsVersion=$desiredMin"
                continue
            }
            $appChanged++
            $willApply = $Apply -and ('ios' -in $autoApplyPlatforms)
            $label = if ($willApply) { 'APPLYING' } else { 'DRY RUN' }
            Write-Output "$label APP '$($app.displayName)' [ios] ($($app.id)): minimumRequiredOsVersion '$($app.minimumRequiredOsVersion)' -> '$desiredMin'"
            if ($willApply) {
                $body = @{ minimumRequiredOsVersion = $desiredMin } | ConvertTo-Json -Compress
                Invoke-RestMethod -Method Patch `
                    -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/iosManagedAppProtections/$($app.id)" `
                    -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } `
                    -Body $body | Out-Null
                $appApplied++
            }
        }
    }

    if ('android' -in $appPlatforms -and $baselines.ContainsKey('android')) {
        $androidApps = Invoke-GraphGet -Token $token -Uri 'https://graph.microsoft.com/v1.0/deviceAppManagement/androidManagedAppProtections?$top=200'
        foreach ($app in $androidApps) {
            if ($app.id -in $excludeIds) {
                Write-Output "Excluded APP: '$($app.displayName)' ($($app.id))"
                continue
            }
            $desiredMin = $baselines['android']
            $needsUpdate = ($app.minimumRequiredOsVersion -ne $desiredMin) -or ($app.minimumRequiredPatchVersion -ne $minimumPatchVersion)
            if (-not $needsUpdate) {
                Write-Output "OK (no change) APP: '$($app.displayName)' [android] minimumRequiredOsVersion=$desiredMin minimumRequiredPatchVersion=$minimumPatchVersion"
                continue
            }
            $appChanged++
            $willApply = $Apply -and ('android' -in $autoApplyPlatforms)
            $label = if ($willApply) { 'APPLYING' } else { 'DRY RUN' }
            Write-Output "$label APP '$($app.displayName)' [android] ($($app.id)): minimumRequiredOsVersion '$($app.minimumRequiredOsVersion)' -> '$desiredMin', minimumRequiredPatchVersion '$($app.minimumRequiredPatchVersion)' -> '$minimumPatchVersion'"
            if ($willApply) {
                $body = @{
                    minimumRequiredOsVersion   = $desiredMin
                    minimumRequiredPatchVersion = $minimumPatchVersion
                } | ConvertTo-Json -Compress
                Invoke-RestMethod -Method Patch `
                    -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/androidManagedAppProtections/$($app.id)" `
                    -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } `
                    -Body $body | Out-Null
                $appApplied++
            }
        }
    }

    Write-Output "App Protection Policies: $appChanged needed changes, $appApplied written."
}

Write-Output "Done."
