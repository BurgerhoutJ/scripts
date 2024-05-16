Install-Module Microsoft.Graph -Force -AllowClobber

Connect-MgGraph

$managedIdentityId = "<MIObjectID>"
$roleName = "DeviceManagementManagedDevices.Read.All, Device.Read.All, Group.ReadWrite.All, Directory.Read.All,	GroupMember.ReadWrite.All"

$msgraph = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$role = $Msgraph.AppRoles| Where-Object {$_.Value -eq $roleName} 

New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentityId -PrincipalId $managedIdentityId -ResourceId $msgraph.Id -AppRoleId $role.Id
 
Disconnect-MgGraph
