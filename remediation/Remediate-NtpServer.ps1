<#
.SYNOPSIS
    Configures Dutch NTP pool servers and the Western European time zone.
.DESCRIPTION
    Updates Windows Time to use a manual NTP peer list and configures the device time zone.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Apply consistent time synchronization and time-zone settings to managed Windows devices.
    What it does: Stops W32Time, configures Dutch NTP pool peers, sets automatic startup and W. Europe Standard Time, then starts W32Time.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

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