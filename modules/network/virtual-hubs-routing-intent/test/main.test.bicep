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
  name: '${shortIdentifier}-tst-vwan-111'
  location: location
  properties: {
    type: 'Standard'
  }
}

resource virtualHub 'Microsoft.Network/virtualHubs@2022-05-01' = {
  name: '${shortIdentifier}-tst-vhub-111'
  location: location
  properties: {
    addressPrefix: '10.1.0.0/16'
    virtualWan: {
      id: virtualWan.id
    }
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: '${shortIdentifier}-tst-fwl-111'
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

/*======================================================================
TEST EXECUTION (Max Parameter Usage)
======================================================================*/
module routingIntentMax '../main.bicep' = {
  name: '${shortIdentifier}-tst-rtint-111'
  params: {
    virtualHubName: virtualHub.name
    routingIntentDestinations: [
      'Internet'
      'PrivateTraffic'
    ]
  }
}

/*======================================================================
TEST EXECUTION (Min Parameter Usage)
======================================================================*/
module routingIntentMin '../main.bicep' = {
  name: '${shortIdentifier}-tst-rtint-111'
  params: {
    virtualHubName: virtualHub.name
  }
}
