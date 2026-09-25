<#
.SYNOPSIS
    Removes the Microsoft 365 Companions AppX package for the current user.
.DESCRIPTION
    Removes every installed package matching Microsoft.M365Companions. The
    script exits successfully when the package is already absent or removed.

    Creator: Jeroen Burgerhout
    Date: 2026-09-25
    Why: Remove Microsoft 365 Companions from managed Windows devices.
    What it does: Finds and removes the current user's Microsoft.M365Companions AppX package.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes
.NOTES
    Pair with Detect-M365Companions.ps1 as the detection script.
#>

$packages = Get-AppxPackage -Name "Microsoft.M365Companions" -ErrorAction SilentlyContinue

if ($null -eq $packages) {
    Write-Output "Microsoft.M365Companions is not installed."
    exit 0
}

try {
    foreach ($package in $packages) {
        Remove-AppxPackage -Package $package.PackageFullName -ErrorAction Stop
        Write-Output "Removed $($package.PackageFullName)."
    }

    exit 0
}
catch {
    Write-Error "Failed to remove Microsoft.M365Companions: $($_.Exception.Message)"
    exit 1
}
