<#
.SYNOPSIS
    Remediates the MSEdge Icon setting on the local device.
.DESCRIPTION
    Applies the required change and exits successfully when the setting is corrected or already compliant.
.NOTES
    Script: Remediate-MSEdgeIcon.ps1
#>

<#
Version: 1.0
Author: 
- Jeroen Burgerhout (burgerhout.org)
Script: Remove-MSEdgeIcon
Description: Script removes the MS Edge Icon from the desktop.
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run this script using the logged-on credentials: No
Enforce script signature check: No
Run script in 64-bit PowerShell: Yes
#> 

Remove-Item -Path "C:\Users\Public\Desktop\Microsoft Edge.lnk"