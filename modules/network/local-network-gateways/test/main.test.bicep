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
TEST EXECUTION
======================================================================*/
module localNetworkGateway1 '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-local-network-gateway1'
  params: {
    name: '${shortIdentifier}-tst-lgw1-${uniqueString(deployment().name, 'localNetworkGateway', location)}'
    location: location
    endpointType: 'ipAddress'
    endpoint: '10.1.2.3'
    addressPrefixes: [
      '10.20.0.0/24'
    ]
    bgpSettings: {
      asn: 65570
      bgpPeeringAddress: '10.20.2.3'
    }
  }
}

module localNetworkGateway2 '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-local-network-gateway2'
  params: {
    name: '${shortIdentifier}-tst-lgw2-${uniqueString(deployment().name, 'localNetworkGateway', location)}'
    location: location
    endpointType: 'fqdn'
    endpoint: 'contoso.gateway.com'
    addressPrefixes: [
      '10.50.0.0/24'
    ]
    bgpSettings: {
      asn: 65580
      bgpPeeringAddress: '10.50.2.3'
    }
    resourceLock: 'CanNotDelete'
  }
}
