@description('Virtual Hub name.')
param virtualHubName string

@description('Optional. The destinations of the routing intent.')
@allowed([
  'Internet'
  'PrivateTraffic'
])
param routingIntentDestinations array = ['Internet', 'PrivateTraffic']

resource virtualHub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  name: virtualHubName
}

@description('The next hop of the routing intent.')
param nextHopId string

resource routingIntentResource 'Microsoft.Network/virtualHubs/routingIntent@2023-04-01' = {
  name: '${virtualHubName}-routingIntent'
  parent: virtualHub
  properties: {
    routingPolicies: [
      {
        destinations: routingIntentDestinations
        name: '${virtualHubName}-routingIntent'
        nextHop: nextHopId
      }
    ]
  }
}

@description('The name of the deployed routing intent.')
output name string = routingIntentResource.name

@description('The resource ID of the deployed virtual hub routing intent.')
output resourceId string = routingIntentResource.id
