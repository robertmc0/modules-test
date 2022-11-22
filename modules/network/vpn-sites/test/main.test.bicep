/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource virtualWan 'Microsoft.Network/virtualWans@2022-05-01' = {
  name: '${shortIdentifier}-tst-vwan-${uniqueString(deployment().name, 'virtualWans', location)}'
  location: location
  properties: {
    type: 'Standard'
  }
}
/*======================================================================
TEST EXECUTION
======================================================================*/
module vpnSiteMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-vpnsite'
  params: {
    name: '${shortIdentifier}-tst-vpnsite-min-${uniqueString(deployment().name, 'vpnSite', location)}'
    location: location
    addressPrefixes: [ '10.70.1.0/24' ]
    deviceVendor: 'FortiNet'
    virtualWanId: virtualWan.id
    vpnSiteLinks: [
      {
        name: 'Link1'
        ipAddress: '10.70.0.2'
        linkProviderName: 'Telstra'
        linkSpeedInMbps: 100
      }
    ]
    resourceLock: 'CanNotDelete'
  }
}

module vpnSite '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vpnsite'
  params: {
    name: '${shortIdentifier}-tst-vpnsite-${uniqueString(deployment().name, 'vpnSite', location)}'
    location: location
    addressPrefixes: [ '10.70.2.0/24' ]
    deviceVendor: 'FortiNet'
    virtualWanId: virtualWan.id
    vpnSiteLinks: [
      {
        name: 'Link1'
        ipAddress: '10.70.0.3'
        linkProviderName: 'Telstra'
        linkSpeedInMbps: 100
      }
    ]
    resourceLock: 'CanNotDelete'
  }
}
