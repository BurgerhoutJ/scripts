<#
.SYNOPSIS
    Detects whether the Microsoft 365 Companions AppX package is installed.
.DESCRIPTION
    Returns exit code 1 when Microsoft.M365Companions is installed so Intune
    can run the remediation script. Returns exit code 0 when the device is
    compliant because the package is absent.

    Creator: Jeroen Burgerhout
    Date: 2026-09-25
    Why: Identify devices that require removal of Microsoft 365 Companions.
    What it does: Checks the current user's AppX packages for Microsoft.M365Companions.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes
.NOTES
    Pair with Remediate-M365Companions.ps1 as the remediation script.
#>

$package = Get-AppxPackage -Name "Microsoft.M365Companions" -ErrorAction SilentlyContinue

if ($null -ne $package) {
    Write-Output "Microsoft.M365Companions is installed."
    exit 1
}

Write-Output "Microsoft.M365Companions is not installed."
exit 0
