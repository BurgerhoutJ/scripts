<#
.SYNOPSIS
    Removes the Windows Update NoAutoUpdate policy value.
.DESCRIPTION
    Removes NoAutoUpdate from the machine-level Windows Update AU policy when present.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Remove the NoAutoUpdate override from managed Windows devices.
    What it does: Checks for NoAutoUpdate and deletes the registry value if it exists.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-AUNoAutoUpdate.ps1
#>

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU).PSObject.Properties.Name -contains 'NoAutoUpdate') {
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate"
}