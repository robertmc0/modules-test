/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

/*======================================================================
TEST EXECUTION
======================================================================*/
module vwanMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-virtual-wan'
  params: {
    location: location
    name: '${uniqueString(deployment().name, location)}minvwan2'
    virtualHubs: [
      {
        name: '${uniqueString(deployment().name, location)}minvhub'
        addressPrefix: '10.1.0.0/23'
        hubRoutingPreference: 'ExpressRoute'
        virtualRouterAutoScaleConfiguration: {
          minCapacity: 2
        }
      }
    ]
  }
}

module vwan '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-virtual-wan'
  params: {
    location: location
    name: '${uniqueString(deployment().name, location)}vwan'
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    disableVpnEncryption: false
    virtualHubs: [
      {
        name: '${uniqueString(deployment().name, location)}vhub'
        addressPrefix: '10.1.0.0/23'
        hubRoutingPreference: 'ExpressRoute'
        virtualRouterAutoScaleConfiguration: {
          minCapacity: 2
        }
      }
    ]
    resourceLock: 'CanNotDelete'
  }
}
