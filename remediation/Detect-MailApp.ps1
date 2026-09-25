<#
.SYNOPSIS
    Detects whether Mail App is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
.NOTES
    Script: Detect-MailApp.ps1
#>

$mailapp= Get-AppxPackage -Name *microsoft.windowscommunicationsapps*

if ($mailapp){
    Write-Output "Windows Mail app is aanwezig"
    Exit 1
}
else {
    Write-Output "Windows Mail app is niet aanwezig"
    Exit 0
}