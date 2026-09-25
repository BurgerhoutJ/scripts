<#
.SYNOPSIS
    Detects whether MSEdge Icon is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
.NOTES
    Script: Detect-MSEdgeIcon.ps1
#>

<#
Version: 1.0
Author: 
- Jeroen Burgerhout (burgerhout.org)
Script: Detect-MSEdgeIcon
Description: Script removes the MS Edge Icon from the desktop.
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run this script using the logged-on credentials: No
Enforce script signature check: No
Run script in 64-bit PowerShell: Yes
#> 

$msedge= Get-Item -Path "C:\Users\Public\Desktop\Microsoft Edge.lnk"

if ($msedge){
    Write-Output "MS Edge shortcut found"
    Exit 1
}
else {
    Write-Output "MS Edge shortcut is not found"
    Exit 0
}