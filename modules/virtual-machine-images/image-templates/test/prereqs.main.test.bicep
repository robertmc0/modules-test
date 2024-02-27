@description('Optional. The geo-location where the resource lives.')
param location string

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string

param deployResourceGroupId string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(resourceGroup().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${shortIdentifier}-tst-umi-${uniqueString(resourceGroup().name, 'umi', location)}'
  location: location
}

resource templateIdentityRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(deployResourceGroupId)
  properties: {
    roleName: 'Azure Image Builder User Managed Id Access'
    description: 'Used for AIB template and ARM deployment script that runs AIB build'
    type: 'customRole'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/delete'
          'Microsoft.Storage/storageAccounts/blobServices/containers/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/write'
          'Microsoft.Resources/deployments/read'
          'Microsoft.Resources/deploymentScripts/read'
          'Microsoft.Resources/deploymentScripts/write'
          'Microsoft.VirtualMachineImages/imageTemplates/run/action'
          'Microsoft.ManagedIdentity/userAssignedIdentities/assign/action'
        ]
        dataActions: [
          'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'
        ]
      }
    ]
    assignableScopes: [
      deployResourceGroupId
    ]
  }
}

resource templateRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(shortIdentifier, userIdentity.name, templateIdentityRoleDefinition.id)
  properties: {
    principalId: userIdentity.properties.principalId
    roleDefinitionId: templateIdentityRoleDefinition.id
    principalType: 'ServicePrincipal'
  }
}

resource networkRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(shortIdentifier, userIdentity.name, '4d97b98b-1d4f-4787-a291-c67834d212e7')
  properties: {
    principalId: userIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // Network Contributor role
    principalType: 'ServicePrincipal'
  }
}

output vnetId string = vnet.id

output userIdentityId string = userIdentity.id

output userIdentityPrincipalId string = userIdentity.properties.principalId
