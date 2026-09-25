<#
.SYNOPSIS
    Detection script to detect if the desired local admin is available on the device
.DESCRIPTION
    This detection script is part of a remediation for creating a local administrator
.EXAMPLE
    Creates a local administrator with a specific name and random password, this can be used with LAPS where the password will be set through a policy
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