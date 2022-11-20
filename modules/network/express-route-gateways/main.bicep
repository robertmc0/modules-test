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

@description('Optional. Configuration for auto scaling.')
@metadata({
  bounds: {
    max: 'Maximum number of scale units deployed for ExpressRoute gateway.'
    min: 'Minimum number of scale units deployed for ExpressRoute gateway.'
  }
})
param autoScaleConfiguration object = {
  bounds: {
    min: 1
  }
}

@description('Optional. Configures this gateway to accept traffic from non Virtual WAN networks.')
param allowNonVirtualWanTraffic bool = true

@description('Optional. Virtual Hub resource ID.')
param virtualHubResourceId string = ''

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${erGateway.name}-${resourceLock}-lck')

resource erGateway 'Microsoft.Network/expressRouteGateways@2022-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    allowNonVirtualWanTraffic: allowNonVirtualWanTraffic
    autoScaleConfiguration: autoScaleConfiguration
    virtualHub: {
      id: virtualHubResourceId
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: erGateway
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed expressRoute gateway.')
output name string = erGateway.name

@description('The resource ID of the deployed expressRoute gateway.')
output resourceId string = erGateway.id
