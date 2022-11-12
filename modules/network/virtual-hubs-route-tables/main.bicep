@description('The resource name.')
param name string

@description('Optional. List of labels associated with this route table.')
param labels array = []

@description('Optional. List of all routes.')
param routes array = []

@description('Virtual Hub name.')
param virtualHubName string

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${virtualHubRoute.name}-${resourceLock}-lck')

resource virtualHub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  name: virtualHubName
}

resource virtualHubRoute 'Microsoft.Network/virtualHubs/hubRouteTables@2022-05-01' = {
  parent: virtualHub
  name: name
  properties: {
    labels: labels
    routes: routes
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: virtualHubRoute
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed virtual hub route.')
output name string = virtualHubRoute.name

@description('The resource ID of the deployed virtual hub route.')
output resourceId string = virtualHubRoute.id
