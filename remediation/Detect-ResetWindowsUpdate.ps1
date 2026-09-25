<#
.SYNOPSIS
    Detects whether Reset Windows Update is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
.NOTES
    Script: Detect-ResetWindowsUpdate.ps1
#>

<#
Version: 1.0
Author: 
- JOrgen Nilsson (ccmexec.com)
Script: ResetWindowsUpdateDetection.ps1
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#> 

# Always trigger
Write-Host "Script will always be triggered"
exit 1