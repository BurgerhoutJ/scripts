<#
.SYNOPSIS
    Enables the Windows AutoAcceptSSO policy at machine level.
.DESCRIPTION
    Creates or updates the machine-level registry value
    HKLM\SOFTWARE\Policies\Microsoft\Windows\AAD\AutoAcceptSsoPermission
    to the expected DWORD value of 1, then verifies the result.

    Creator: Jeroen Burgerhout
    Date: 2026-09-25
    Why: Configure AutoAcceptSSO consistently on managed Windows devices.
    What it does: Sets and verifies the AutoAcceptSsoPermission policy value to 1.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Exit 0 = Remediation succeeded
    Exit 1 = Remediation failed
#>

$RegPath   = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AAD'
$ValueName = 'AutoAcceptSsoPermission'
$Value     = 1

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force -ErrorAction Stop | Out-Null
    }

    New-ItemProperty -Path $RegPath -Name $ValueName -Value $Value -PropertyType DWord -Force -ErrorAction Stop | Out-Null

    # Verify
    $current = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop |
        Select-Object -ExpandProperty $ValueName

    if ($current -eq $Value) {
        Write-Output "Remediation succeeded: $ValueName = $current"
        exit 0
    }
    else {
        Write-Output "Remediation failed: $ValueName = $current (expected $Value)"
        exit 1
    }
}
catch {
    Write-Output "Remediation failed: $($_.Exception.Message)"
    exit 1
}
