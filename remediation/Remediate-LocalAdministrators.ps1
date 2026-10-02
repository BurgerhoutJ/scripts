<#
.SYNOPSIS
    Adds the last logged-on SAM user to local Administrators.
.DESCRIPTION
    Reads LastLoggedOnSAMUser from LogonUI and requests local administrator membership for that user.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Grant local administrator membership to the last logged-on user on targeted devices.
    What it does: Runs net localgroup Administrators with the recorded SAM user and the /add option.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

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