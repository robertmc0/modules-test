metadata name = 'Hub Routing Intent Module'
metadata description = 'This module deploys Microsoft.Network/virtualHubs routingIntent.'
metadata owner = 'Arinco'

@description('Virtual Hub name.')
param virtualHubName string

@description('Optional. The destinations of the routing intent.')
@allowed([
  'Internet'
  'PrivateTraffic'
])
param routingIntentDestinations array = [ 'Internet', 'PrivateTraffic' ]

resource virtualHub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  name: virtualHubName
}

@description('The routing policies of the routing intent.')
var routingPolicies = routingIntentDestinations == [ 'Internet', 'PrivateTraffic' ] ? [
  {
    destinations: [ 'Internet' ]
    name: '${virtualHubName}-routingIntentPrivate'
    nextHop: virtualHub.properties.azureFirewall.id
  }
  {
    destinations: [ 'PrivateTraffic' ]
    name: '${virtualHubName}-routingIntentInternet'
    nextHop: virtualHub.properties.azureFirewall.id
  }
] : routingIntentDestinations == [ 'PrivateTraffic' ] ? [
  {
    destinations: [ 'PrivateTraffic' ]
    name: '${virtualHubName}-routingIntentPrivateOnly'
    nextHop: virtualHub.properties.azureFirewall.id
  }
] : routingIntentDestinations == [ 'Internet' ] ? [
  {
    destinations: [ 'Internet' ]
    name: '${virtualHubName}-routingIntentInternetOnly'
    nextHop: virtualHub.properties.azureFirewall.id
  }
] : []

@description('The routing intent resource.')
resource routingIntentResource 'Microsoft.Network/virtualHubs/routingIntent@2023-04-01' = {
  name: '${virtualHubName}-routingIntent'
  parent: virtualHub
  properties: {
    routingPolicies: routingPolicies
  }
}

@description('The name of the deployed routing intent.')
output name string = routingIntentResource.name

@description('The resource ID of the deployed virtual hub routing intent.')
output resourceId string = routingIntentResource.id
