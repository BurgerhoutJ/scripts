<#
.SYNOPSIS
    Remediates the Tenant Administrators setting on the local device.
.DESCRIPTION
    Applies the required change and exits successfully when the setting is corrected or already compliant.
.NOTES
    Script: Remediate-TenantAdministrators.ps1
#>

<#
Version: 1.0
Author: 
- Jeroen Burgerhout (burgerhout.org)
Script: Remediate-TenantAdministrators
Description: Remediation Script: Add two Entra ID SIDs to the Local Administrators group if they are not already members
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run this script using the logged-on credentials: Yes
Enforce script signature check: No
Run script in64-bit PowerShell: Yes
#>

# Define the Entra ID SIDs to add
# Replace these with your actual Entra ID SIDs
$EntraIDSID1 = "S-1-12-1-2006554087-1077730195-384167608-1848081268"  # Azure AD Joined Device Local Administrator
$EntraIDSID2 = "S-1-12-1-180637778-1132252887-4221403304-2124284756"  # Global Administrator

# Get the local Administrators group
$AdministratorsGroup = [ADSI]"WinNT://./Administrators"

# Function to check if SID is in the Local Administrators group
function Is-SIDInAdministratorsGroup {
    param ([string]$SID)
    $Members = $AdministratorsGroup.PSBase.Invoke("Members") | ForEach-Object {
        $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }
    return $Members -contains $SID
}

# Function to add SID to the Local Administrators group
function Add-SIDToAdministratorsGroup {
    param ([string]$SID)
    $User = [ADSI]"WinNT://$SID,user"
    $AdministratorsGroup.PSBase.Invoke("Add", $User.PSBase.Path)
    Write-Output "$SID has been added to the Local Administrators group."
}

# Check if the SIDs are already in the Administrators group and add them if necessary
$SID1InAdminGroup = Is-SIDInAdministratorsGroup -SID $EntraIDSID1
$SID2InAdminGroup = Is-SIDInAdministratorsGroup -SID $EntraIDSID2

if (-not $SID1InAdminGroup) {
    Add-SIDToAdministratorsGroup -SID $EntraIDSID1
} else {
    Write-Output "Entra ID SID1 is already in the Local Administrators group."
}

if (-not $SID2InAdminGroup) {
    Add-SIDToAdministratorsGroup -SID $EntraIDSID2
} else {
    Write-Output "Entra ID SID2 is already in the Local Administrators group."
}
