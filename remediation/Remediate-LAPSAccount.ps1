<#
.SYNOPSIS
    Creates the WEBLAPS local account when it is missing.
.DESCRIPTION
    Creates the configured local account with a generated password for subsequent LAPS management.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Ensure the local account intended for LAPS management exists on managed Windows devices.
    What it does: Creates WEBLAPS if absent, returning exit code 0 on creation or 1 on a caught creation error.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.EXAMPLE
    Creates WEBLAPS with a generated password; does not configure LAPS policy or administrator group membership.
.NOTES
    Filename: Remediate-LAPSAccount.ps1
    Author: Jeroen Ebus (https://manage-the.cloud) 
    Modified date: 2023-05-25
    Version 1.0 - Release notes/details
    Run this script using the logged-on credentials: No
    Enforce script signature check: No
    Run script in 64-bit PowerShell: Yes    
#>

# Function created with the help of https://www.sharepointdiary.com/2020/04/powershell-generate-random-password.html

Function Get-RandomPassword {
    #define parameters
    param([int]$PasswordLength = 100)
 
    #ASCII Character set for Password
    $CharacterSet = @{
        Uppercase   = (97..122) | Get-Random -Count 10 | ForEach-Object { [char]$_ }
        Lowercase   = (65..90)  | Get-Random -Count 10 | ForEach-Object { [char]$_ }
        Numeric     = (48..57)  | Get-Random -Count 10 | ForEach-Object { [char]$_ }
        SpecialChar = (33..47) + (58..64) + (91..96) + (123..126) | Get-Random -Count 10 | ForEach-Object { [char]$_ }
    }
 
    #Frame Random Password from given character set
    $StringSet = $CharacterSet.Uppercase + $CharacterSet.Lowercase + $CharacterSet.Numeric + $CharacterSet.SpecialChar
 
    -join (Get-Random -Count $PasswordLength -InputObject $StringSet)
}

# Actual remediation! Based on https://cloudinfra.net/create-a-local-admin-using-intune-and-powershell/

$userName = "WEBLAPS"
$userexist = (Get-LocalUser).Name -Contains $userName
$password = Get-RandomPassword | ConvertTo-SecureString -AsPlainText -Force

if ($userexist -eq $false) {
    try { 
        New-LocalUser -Name $username -Description "Local Administrator account managed through LAPS" -Password $password
        Exit 0
    }   
    Catch {
        Write-error $_
        Exit 1
    }
} 