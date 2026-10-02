<#
.SYNOPSIS
    Removes consumer Microsoft Teams for the current user.
.DESCRIPTION
    Finds and removes the current user's AppX packages matching *MicrosoftTeams*.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Remove the unwanted consumer Microsoft Teams package from managed Windows user profiles.
    What it does: Runs Remove-AppxPackage for matching packages and reports success or an error.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-Win11TeamsClientConsumer.ps1
#>

try{
    Get-AppxPackage -Name *MicrosoftTeams* | Remove-AppxPackage -ErrorAction stop
    Write-Host "Microsoft Consumer Teams successfully removed."

}
catch{
    Write-Error "Error removing Microsoft Consumer Teams."
}