<#
.SYNOPSIS
    Detects whether Kiosk User 0 is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
.NOTES
    Script: Detect-KioskUser0.ps1
#>

# Detection Script
$autoAdminLogon = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -ErrorAction SilentlyContinue).AutoAdminLogon
$defaultUserName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -ErrorAction SilentlyContinue).DefaultUserName
$disableLockWorkstation = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DisableLockWorkstation" -ErrorAction SilentlyContinue).DisableLockWorkstation
$isConnectedAutoLogon = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "IsConnectedAutoLogon" -ErrorAction SilentlyContinue).IsConnectedAutoLogon

if (($autoAdminLogon -eq "1") -and 
    ($defaultUserName -eq "kioskUser0") -and 
    ($disableLockWorkstation -eq 1) -and 
    ($isConnectedAutoLogon -eq 0)) {
    Write-Output "Found"
    exit 0
} else {
    Write-Output "NotFound"
    exit 1
}