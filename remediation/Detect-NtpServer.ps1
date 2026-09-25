<#
.SYNOPSIS
    Detects whether Ntp Server is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
.NOTES
    Script: Detect-NtpServer.ps1
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