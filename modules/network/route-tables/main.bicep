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

@description('Optional. Whether to disable the routes learned by BGP on that route table. True means disable.')
param disableBgpRoutePropagation bool = false

@description('Collection of routes contained within a route table.')
@metadata({
  name: 'Route name.'
  addressPrefix: 'The destination CIDR to which the route applies.'
  hasBgpOverride: 'A value indicating whether this route overrides overlapping BGP routes regardless of LPM.'
  nextHopIpAddress: 'The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is "VirtualAppliance".'
  nextHopType: 'The type of Azure hop the packet should be sent to. Allowed values:  "Internet", "None", "VirtualAppliance", "VirtualNetworkGateway" or "VnetLocal".'
})
param routes array = []

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${routeTable.name}-${resourceLock}-lck')

resource routeTable 'Microsoft.Network/routeTables@2022-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [for route in routes: {
      name: route.name
      properties: {
        addressPrefix: route.addressPrefix
        hasBgpOverride: contains(route, 'hasBgpOverride') ? route.hasBgpOverride : null
        nextHopIpAddress: contains(route, 'nextHopIpAddress') ? route.nextHopIpAddress : null
        nextHopType: route.nextHopType
      }
    }]
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: routeTable
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed route table.')
output name string = routeTable.name

@description('The resource ID of the deployed route table.')
output resourceId string = routeTable.id
