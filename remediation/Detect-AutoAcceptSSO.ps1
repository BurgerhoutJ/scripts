<#
.SYNOPSIS
    Detects whether Windows AutoAcceptSSO is enabled by policy.
.DESCRIPTION
    Checks whether the machine-level registry value
    HKLM\SOFTWARE\Policies\Microsoft\Windows\AAD\AutoAcceptSsoPermission
    is set to the expected DWORD value of 1.

    Creator: Jeroen Burgerhout
    Date: 2026-09-25
    Why: Detect devices where the AutoAcceptSSO policy is missing or incorrectly configured.
    What it does: Returns exit code 0 when the policy equals 1; otherwise returns exit code 1.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Exit 0 = Compliant (no remediation needed)
    Exit 1 = Non-compliant (remediation will run)
#>

$RegPath   = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AAD'
$ValueName = 'AutoAcceptSsoPermission'
$Expected  = 1

try {
    $current = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop |
        Select-Object -ExpandProperty $ValueName

    if ($current -eq $Expected) {
        Write-Output "Compliant: $ValueName = $current"
        exit 0
    }
    else {
        Write-Output "Non-compliant: $ValueName = $current (expected $Expected)"
        exit 1
    }
}
catch {
    Write-Output "Non-compliant: $ValueName not found at $RegPath"
    exit 1
}
