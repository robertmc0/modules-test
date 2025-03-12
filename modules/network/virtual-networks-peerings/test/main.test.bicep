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
resource vnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet1-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet2-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.50.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.50.0.0/24'
        }
      }
    ]
  }
}
/*======================================================================
TEST EXECUTION
======================================================================*/
module vnet1Peering '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vnet1-peer'
  params: {
    name: '${shortIdentifier}-tst-peering-${uniqueString(deployment().name, 'vnet1Peering', location)}'
    sourceVirtualNetworkName: vnet1.name
    remoteVirtualNetworkId: vnet2.id
    useRemoteGateways: false
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
  }
}

module vnet2Peering '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vnet2-peer'
  params: {
    name: '${shortIdentifier}-tst-peering-${uniqueString(deployment().name, 'vnet2Peering', location)}'
    sourceVirtualNetworkName: vnet2.name
    remoteVirtualNetworkId: vnet1.id
    useRemoteGateways: false
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
  }
}
