<#
.SYNOPSIS
    Removes Dev Home for the current user.
.DESCRIPTION
    Finds and removes the current user's AppX packages matching *DevHome*.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Remove the unwanted Dev Home application from managed Windows user profiles.
    What it does: Runs Remove-AppxPackage for matching packages and reports success or an error.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-DevHome.ps1
#>

try{
    Get-AppxPackage -Name *DevHome* | Remove-AppxPackage -ErrorAction stop
    Write-Host "Dev Home successfully removed."

}
catch{
    Write-Error "Error removing Dev Home."
}