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

@description('Optional. Link Private DNS zone to an existing virtual network.')
param enableVirtualNeworkLink bool = false

@description('Optional. Existing virtual network resource ID(s). Only required if enableVirtualNeworkLink equals true.')
param virtualNetworkResourceIds array = []

@description('Optional. Enable auto-registration of virtual machine records in the virtual network for the Private DNS zone.')
param registrationEnabled bool = false

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourceLock string = 'NotSpecified'

var lockName = toLower('${privateDnsZone.name}-${resourceLock}-lck')
var vnetLinkSuffix = '-vlnk'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: location
  tags: tags
}

resource privateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for virtualNetworkResourceId in virtualNetworkResourceIds: if (enableVirtualNeworkLink) {
  parent: privateDnsZone
  name: '${last(split(virtualNetworkResourceId, '/'))}${vnetLinkSuffix}'
  location: location
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: virtualNetworkResourceId
    }
  }
}]

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: privateDnsZone
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed private dns zone.')
output name string = privateDnsZone.name

@description('The resource ID of the deployed private dns zone.')
output resourceId string = privateDnsZone.id
