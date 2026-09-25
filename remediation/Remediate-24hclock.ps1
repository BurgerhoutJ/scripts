<#
.SYNOPSIS
    Remediates the 24 hclock setting on the local device.
.DESCRIPTION
    Applies the required change and exits successfully when the setting is corrected or already compliant.
.NOTES
    Script: Remediate-24hclock.ps1
#>

# Remediation Script
Write-Host "Setting Short time format"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value "HH:mm"

Write-Host "Setting Long time format"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat -Value "HH:mm:ss"

# Exit with code 0 to indicate successful remediation
exit 0
