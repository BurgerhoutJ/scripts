<#
.SYNOPSIS
    Remediates the Kiosk User 0 setting on the local device.
.DESCRIPTION
    Applies the required change and exits successfully when the setting is corrected or already compliant.
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
