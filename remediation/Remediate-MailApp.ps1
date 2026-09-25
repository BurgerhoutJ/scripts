<#
.SYNOPSIS
    Remediates the Mail App setting on the local device.
.DESCRIPTION
    Applies the required change and exits successfully when the setting is corrected or already compliant.
.NOTES
    Script: Remediate-MailApp.ps1
#>

Get-AppxPackage *microsoft.windowscommunicationsapps* | Remove-AppxPackage