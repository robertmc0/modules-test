metadata name = 'Route Tables Module'
metadata description = 'This module deploys Microsoft.Network/virtualHubs hubVirtualNetworkConnections.'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('Virtual Hub name.')
param virtualHubName string

@description('Optional. Enable internet security.')
param enableInternetSecurity bool = true

@description('Remote virtual network resource ID.')
param remoteVirtualNetworkId string

@description('Optional. The resource ID of the RouteTable associated with this RoutingConfiguration.')
param associatedRouteTableId string = ''

@description('Optional. The list of RouteTables to advertise the routes to.')
@metadata({
  labels: [
    'The list of labels.'
  ]
  ids: [
    {
      id: 'Resource ID of the RouteTable.'
    }
  ]
})
param propagatedRouteTables object = {}

resource virtualHub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  name: virtualHubName
}

resource virtualHubConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2022-05-01' = {
  parent: virtualHub
  name: name
  properties: {
    enableInternetSecurity: enableInternetSecurity
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkId
    }
    routingConfiguration: {
      associatedRouteTable: associatedRouteTableId != ''
        ? {
            id: associatedRouteTableId
          }
        : null
      propagatedRouteTables: propagatedRouteTables
    }
  }
}

@description('The name of the deployed virtual hub route.')
output name string = virtualHubConnection.name

@description('The resource ID of the deployed virtual hub route.')
output resourceId string = virtualHubConnection.id
