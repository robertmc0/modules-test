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

resource virtualHub 'Microsoft.Network/virtualHubs@2022-05-01' = {
  name: '${shortIdentifier}-tst-vhub-${uniqueString(deployment().name, 'virtualHubs', location)}'
  location: location
  properties: {
    addressPrefix: '10.1.0.0/16'
    virtualWan: {
      id: virtualWan.id
    }
  }
}

resource virtualHubRoute 'Microsoft.Network/virtualHubs/hubRouteTables@2022-05-01' = {
  parent: virtualHub
  name: '${shortIdentifier}-tst-vhubrt-${uniqueString(deployment().name, 'hubRouteTables', location)}'
  properties: {
    labels: [
      'internet'
    ]
    routes: [
      {
        destinations: [
          '0.0.0.0/0'
        ]
        destinationType: 'CIDR'
        name: 'default'
        nextHop: firewall.id
        nextHopType: 'ResourceId'
      }
    ]
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: '${shortIdentifier}-tst-fwl-${uniqueString(deployment().name, 'azureFirewalls', location)}'
  location: location
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    virtualHub: {
      id: virtualHub.id
    }
  }
}

resource vnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet1-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'SpokeSubnet1'
        properties: {
          addressPrefix: '10.20.0.0/24'
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
        '10.30.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'SpokeSubnet1'
        properties: {
          addressPrefix: '10.30.0.0/24'
        }
      }
    ]
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module hubVnetConnectionMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-hub-connection'
  params: {
    name: '${shortIdentifier}-tst-min-peer-${uniqueString(deployment().name, 'hubVnetConnection', location)}'
    virtualHubName: virtualHub.name
    remoteVirtualNetworkId: vnet1.id
  }
}

module hubVnetConnection '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-hub-connection'
  params: {
    name: '${shortIdentifier}-tst-peer-${uniqueString(deployment().name, 'hubVnetConnection', location)}'
    virtualHubName: virtualHub.name
    remoteVirtualNetworkId: vnet2.id
    associatedRouteTableId: virtualHubRoute.id
    enableInternetSecurity: true
    propagatedRouteTables: {
      labels: [
        'internet'
      ]
      ids: [
        {
          id: virtualHubRoute.id
        }
      ]
    }
  }
}
