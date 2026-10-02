<#
.SYNOPSIS
    Configures kioskUser0 automatic logon settings.
.DESCRIPTION
    Updates the machine-level Winlogon values used by the kioskUser0 configuration.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Apply consistent automatic logon settings to managed kiosk devices.
    What it does: Sets AutoAdminLogon to 1, DefaultUserName to kioskUser0, DisableLockWorkstation to 1, and IsConnectedAutoLogon to 0.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-KioskUser0.ps1
#>

# Remediation Script
try {
    # Set AutoAdminLogon to "1"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1" -Type String
    
    # Set DefaultUserName to "kioskUser0"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value "kioskUser0" -Type String
    
    # Set DisableLockWorkstation to 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DisableLockWorkstation" -Value 1 -Type DWord
    
    # Set IsConnectedAutoLogon to 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "IsConnectedAutoLogon" -Value 0 -Type DWord

    Write-Output "Remediation applied successfully."
} catch {
    Write-Output "Remediation failed: $_"
}
