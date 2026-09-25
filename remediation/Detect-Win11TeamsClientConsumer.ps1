<#
.SYNOPSIS
    Detects whether Win 11 Teams Client Consumer is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
.NOTES
    Script: Detect-Win11TeamsClientConsumer.ps1
#>

<#
Version: 1.0
Author: 
- Jeroen Burgerhout (burgerhout.org)
Script: Detect-Win11TeamsClientConsumer
Description: Script detects the new Microsoft Teams consumer app on Windows 11.
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run this script using the logged-on credentials: Yes
Enforce script signature check: No
Run script in 64-bit PowerShell: Yes
#> 

if (Get-AppxPackage -Name *MicrosoftTeams*) {
write-host "Microsoft Consumer Teams found."

exit 1
}

else {
write-host "Microsoft Consumer Teams not found."

exit 0
}