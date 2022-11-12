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

@description('Optional. Allow branch to branch traffic.')
param allowBranchToBranchTraffic bool = true

@description('Optional. Allow Vnet to Vnet traffic.')
param allowVnetToVnetTraffic bool = true

@description('Optional. Vpn encryption to be disabled or not.')
param disableVpnEncryption bool = false

@description('Optional. The type of the VirtualWAN.')
@allowed([
  'Standard'
  'Basic'
])
param type string = 'Standard'

@description('Optional. Virtual Hub configuration.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs?pivots=deployment-language-bicep'
  example: {
    name: 'string'
    addressPrefix: 'string'
    hubRoutingPreference: 'string'
    virtualRouterAutoScaleConfiguration: {
      minCapacity: 2
    }
  }
})
param virtualHubs array = []

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${virtualWan.name}-${resourceLock}-lck')

resource virtualWan 'Microsoft.Network/virtualWans@2022-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    type: type
  }
}

resource virtualHub 'Microsoft.Network/virtualHubs@2022-05-01' = [for hub in virtualHubs: {
  name: hub.name
  location: location
  tags: tags
  properties: {
    addressPrefix: hub.addressPrefix
    hubRoutingPreference: contains(hub, 'hubRoutingPreference') ? hub.hubRoutingPreference : null
    virtualRouterAutoScaleConfiguration: contains(hub, 'virtualRouterAutoScaleConfiguration') ? hub.virtualRouterAutoScaleConfiguration : null
    virtualWan: {
      id: virtualWan.id
    }
  }
}]

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: virtualWan
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed virtual wan.')
output name string = virtualWan.name

@description('The resource ID of the deployed virtual wan.')
output resourceId string = virtualWan.id

@description('List of virtual hubs associated to the virtual wan.')
output hubs array = [for i in range(0, length(virtualHubs)): {
  name: virtualHub[i].name
  id: virtualHub[i].id
}]
