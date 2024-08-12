Install-Module Microsoft.Graph -Force -AllowClobber

Connect-MgGraph -Scopes Application.Read.All, AppRoleAssignment.ReadWrite.All

$MId = "object-id of MI"
$roleNames = "DeviceManagementManagedDevices.Read.All", "Device.Read.All", "Group.ReadWrite.All", "Directory.Read.All", "GroupMember.ReadWrite.All"

$getPerms = (Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'").approles | Where-Object Value -in $roleNames
foreach ($perm in $getPerms) {
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MID -PrincipalId $MID -ResourceId (Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'").id -AppRoleId $perm.id
}

Disconnect-MgGraph
