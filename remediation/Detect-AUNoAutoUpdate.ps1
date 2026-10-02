<#
.SYNOPSIS
    Detects the Windows Update NoAutoUpdate policy value.
.DESCRIPTION
    Checks whether the machine-level Windows Update AU policy contains NoAutoUpdate.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify devices with a NoAutoUpdate policy value that should be removed.
    What it does: Returns exit code 1 when NoAutoUpdate exists, regardless of its value; otherwise returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-AUNoAutoUpdate.ps1
#>

if((Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU).PSObject.Properties.Name -contains 'NoAutoUpdate') {
    Exit 1
} else {
    exit 0
}