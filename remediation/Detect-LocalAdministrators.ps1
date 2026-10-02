<#
.SYNOPSIS
    Detects administrator membership for the last logged-on SAM user.
.DESCRIPTION
    Reads LastLoggedOnSAMUser from LogonUI and checks the local Administrators group listing.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify devices where the last logged-on user is not a local administrator.
    What it does: Returns exit code 0 when the user appears in the group listing; otherwise returns exit code 1.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-LocalAdministrators.ps1
#>

# Detection Script: Check if the current logged-on user is in the Local Administrators group

# Get the current logged on user
#Return SAM
$key1 = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
$subKey1 = $key1.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI")
$SAM = $subKey1.GetValue("LastLoggedOnSAMUser")

$currentUser = "$SAM"

# Get the list of users in the Administrators group
$adminGroupMembers = net localgroup administrators

# Check if the current user is part of the Administrators group
if ($adminGroupMembers -contains $currentUser) {
    Write-Output "The current user is a part of the Administrators group."
    exit 0  # Exit code 0 means compliant in Intune
} else {
    Write-Output "The current user is NOT a part of the Administrators group."
    exit 1  # Exit code 1 means non-compliant in Intune
}