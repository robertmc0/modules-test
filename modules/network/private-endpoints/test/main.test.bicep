/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/

@description('The location to deploy resources to')
param location string = 'australiaeast'

var privateDnsZoneService = 'vault'
var privateDnsZoneDns = 'privatelink.vaultcore.azure.net'

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: 'arincokv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'arinco-vnet'
  location: location
  properties: {
    
  }  
  resource subnet 'subnets@2021-05-01' = {
    name: 'arinco-subnet'
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneDns
  location: location
  properties: {
  }
}

module privateEndpoint '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-private-endpoint'
  params: {
    location: location
    type: privateDnsZoneService
    lock: 'ReadOnly'
    targetResourceId: keyVault.id
    targetResourceName: keyVault.name
    subnetId: vnet::subnet.id
    privateDnsZoneId: privateDnsZone.id
  }
}
