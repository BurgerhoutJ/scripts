<#
.SYNOPSIS
    Detects whether Windows Time uses the default Microsoft NTP server value.
.DESCRIPTION
    Reads the machine-level Windows Time NtpServer registry value.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify devices still configured with time.windows.com,0x9.
    What it does: Returns exit code 1 for time.windows.com,0x9; otherwise returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-NtpServer.ps1
    Does not verify the replacement peer list, service startup type, or time zone.
#>

$ntpserver= Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\' -Name NtpServer

if ($ntpserver -eq "time.windows.com,0x9"){
    Write-Output "NtpServer staat verkeerd"
    Exit 1
}
else {
    Write-Output "NtpServer staat goed"
    Exit 0
}