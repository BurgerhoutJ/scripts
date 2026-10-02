<#
.SYNOPSIS
    Detects whether kioskUser0 automatic logon settings are configured.
.DESCRIPTION
    Checks four machine-level Winlogon values used by the kioskUser0 configuration.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify kiosk devices whose automatic logon settings do not match the expected configuration.
    What it does: Returns exit code 0 when all four Winlogon values match; otherwise returns exit code 1.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

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