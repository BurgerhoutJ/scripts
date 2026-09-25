<#
.SYNOPSIS
    Remediates the Ntp Server setting on the local device.
.DESCRIPTION
    Applies the required change and exits successfully when the setting is corrected or already compliant.
.NOTES
    Script: Remediate-NtpServer.ps1
#>

# Stopping time service"
Stop-Service -Name "W32Time"

# Settings time servers
w32tm.exe /config /syncfromflags:manual /manualpeerlist:"0.nl.pool.ntp.org 1.nl.pool.ntp.org 2.nl.pool.ntp.org 3.nl.pool.ntp.org,0x9"

# Set time service to automatic
Set-Service -Name "W32Time" -StartupType "Automatic"

# Set the correct time zone
Set-TimeZone -Id "W. Europe Standard Time" -PassThru

# Starting time service
Start-Service -Name "W32Time"