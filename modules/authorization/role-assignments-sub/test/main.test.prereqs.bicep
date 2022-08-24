@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
}

output principalId string = userIdentity.properties.principalId
