param userAssignedIdentities_WAD_Identity_name string = 'WAD-Identity'
param resourceLocation string 
resource userAssignedIdentities_WAD_Identity_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userAssignedIdentities_WAD_Identity_name
  location: resourceLocation
}
