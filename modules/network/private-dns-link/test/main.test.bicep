/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = 'global'

@description('Optional. Hub resource group name.')
param hubResourceGroupName string = 'arn-ae-hub-rg'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

var dnsZoneLinking = [
  'privatelink.vaultcore.azure.net'
  'privatelink.monitor.azure.com'
]

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

/*======================================================================
TEST EXECUTION
======================================================================*/
module privateDnsZonesHub '../main.bicep' = [for (privateDnsZone, i) in dnsZoneLinking: {
  scope: resourceGroup(hubResourceGroupName)
  dependsOn: []
  name: 'private-dns-zones-${uniqueString(deployment().name, location, '${i}')}'
  params: {
    name: toLower(privateDnsZone)
    location: location
    virtualNetworkResourceId: vnet1.id
  }
}]
