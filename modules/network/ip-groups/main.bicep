@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('IpAddresses/IpAddressPrefixes in the IpGroups resource.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/ipgroups?pivots=deployment-language-bicep#ipgrouppropertiesformat'
  example: [
    'string'
  ]
})
param ipAddresses array

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${ipGroup.name}-${resourceLock}-lck')

resource ipGroup 'Microsoft.Network/ipGroups@2022-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipAddresses: ipAddresses
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: ipGroup
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed IpGroup.')
output name string = ipGroup.name

@description('The resource ID of the deployed IpGroup.')
output resourceId string = ipGroup.id
