<#
.SYNOPSIS
    Detects whether the WEBLAPS local account exists.
.DESCRIPTION
    Checks local user accounts for the configured WEBLAPS account name.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify devices missing the local account intended for LAPS management.
    What it does: Returns exit code 0 when WEBLAPS exists; otherwise returns exit code 1.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.EXAMPLE
    Checks for WEBLAPS without creating an account or changing group membership.
.NOTES
    Filename: Detect-LAPSAccount.ps1
    Author: Jeroen Ebus (https://manage-the.cloud) 
    Modified date: 2023-05-25
    Version 1.0 - Release notes/details
    Run this script using the logged-on credentials: No
    Enforce script signature check: No
    Run script in 64-bit PowerShell: Yes
#>

# Dection script! Based on https://cloudinfra.net/create-a-local-admin-using-intune-and-powershell/

$userName = "WEBLAPS"
$Userexist = (Get-LocalUser).Name -Contains $userName

if ($userexist) { 
    Write-Host "$userName exist" 
    Exit 0
} 
Else {
    Write-Host "$userName does not Exists"
    Exit 1
}