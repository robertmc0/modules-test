/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

/*======================================================================
TEST EXECUTION
======================================================================*/
module routeTableMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-route-table'
  params: {
    name: '${uniqueString(deployment().name, location)}minrtble'
    location: location
  }
}

module routeTable '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-route-table'
  params: {
    name: '${uniqueString(deployment().name, location)}rtble'
    location: location
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'to-mskms'
        addressPrefix: '23.102.135.246/32'
        nextHopType: 'Internet'
      }
      {
        name: 'to-nva'
        addressPrefix: '10.0.1.0/24'
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: '10.20.1.4'
      }
      {
        name: 'to-onprem'
        addressPrefix: '10.0.3.0/24'
        nextHopType: 'VirtualNetworkGateway'
      }
      {
        name: 'to-dbs'
        addressPrefix: '10.0.4.0/24'
        nextHopType: 'VnetLocal'
      }
    ]
    resourceLock: 'CanNotDelete'
  }
}
