<#
.SYNOPSIS
    Detects whether Adobe Aanbiedingen is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
.NOTES
    Script: Detect-AdobeAanbiedingen.ps1
#>

<#
Version: 1.0
Author: 
- Jeroen Burgerhout (burgerhout.org)
Script: Detect-AdobeAanbiedingen
Description: Script removes the AdobeAanbiedingen shortcut.
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run this script using the logged-on credentials: No
Enforce script signature check: No
Run script in 64-bit PowerShell: Yes
#> 

$msedge= Get-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Aanbiedingen.lnk"

if ($msedge){
    Write-Output "AdobeA anbiedingen shortcut found"
    Exit 1
}
else {
    Write-Output "Adobe Aanbiedingen shortcut not found"
    Exit 0
}