<#
.SYNOPSIS
    Remediates the Local Administrators setting on the local device.
.DESCRIPTION
    Applies the required change and exits successfully when the setting is corrected or already compliant.
.NOTES
    Script: Remediate-LocalAdministrators.ps1
#>

# Remediation Script: Add the current logged-on user to the Local Administrators group if they are not already a member

#Return SAM
$key1 = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
$subKey1 = $key1.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI")
$SAM = $subKey1.GetValue("LastLoggedOnSAMUser")

#Add Logged on user to Local Group
# Add-LocalGroupMember -Group "Administrators" -Member "$SAM"
net localgroup "Administrators" $SAM /add