/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

var privateDnsZoneName = 'privatelink.vaultcore.azure.net'

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
        name: 'subnet1'
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
        name: 'subnet1'
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
module privateEndpoint '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-private-dns-zone'
  params: {
    name: privateDnsZoneName
    location: 'global'
    registrationEnabled: true
    virtualNetworkResourceIds: [
      vnet1.id
      vnet2.id
    ]
    enableVirtualNeworkLink: true
    resourceLock: 'CanNotDelete'
  }
}
