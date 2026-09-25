<#
.SYNOPSIS
    Remediates the Win 11 Teams Client Consumer setting on the local device.
.DESCRIPTION
    Applies the required change and exits successfully when the setting is corrected or already compliant.
.NOTES
    Script: Remediate-Win11TeamsClientConsumer.ps1
#>

<#
Version: 1.0
Author: 
- Jeroen Burgerhout (burgerhout.org)
Script: Remove-Win11TeamsClientConsumer
Description: Script removes the new Microsoft Teams consumer app on Windows 11, because this app can only be used with personal Microsoft accounts.
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run this script using the logged-on credentials: Yes
Enforce script signature check: No
Run script in 64-bit PowerShell: Yes
#> 

try{
    Get-AppxPackage -Name *MicrosoftTeams* | Remove-AppxPackage -ErrorAction stop
    Write-Host "Microsoft Consumer Teams successfully removed."

}
catch{
    Write-Error "Error removing Microsoft Consumer Teams."
}