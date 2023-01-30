/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

var privateDnsZoneDns = 'privatelink.vaultcore.azure.net'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${shortIdentifier}-tst-kv-${uniqueString(deployment().name, 'keyVault', location)}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${shortIdentifier}tst${uniqueString(deployment().name, 'storage', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'PrivateEndpoints'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneDns
  location: 'global'
  properties: {
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module privateEndpointNoDns '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-private-endpoint'
  params: {
    location: location
    resourcelock: 'CanNotDelete'
    targetResourceId: storage.id
    targetResourceName: storage.name
    targetSubResourceType: 'blob'
    subnetId: vnet.properties.subnets[0].id
  }
}

module privateEndpointWithDns '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-private-endpoint-dns'
  params: {
    location: location
    resourcelock: 'CanNotDelete'
    targetResourceId: keyVault.id
    targetResourceName: keyVault.name
    targetSubResourceType: 'vault'
    subnetId: vnet.properties.subnets[0].id
    privateDnsZoneId: privateDnsZone.id
  }
}

output ipAddress string = privateEndpointWithDns.outputs.ipAddress
output ipAllocationMethod string = privateEndpointWithDns.outputs.ipAllocationMethod
