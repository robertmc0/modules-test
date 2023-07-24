@description('Optional. Existing virtual network resource ID(s).')
param virtualNetworkResourceId string

@description('Optional. The Private DNS Zone name.')
param registrationEnabled bool = false

@description('The resource name.')
param name string

@description('Optional. The location where the Private DNS Zone is deployed')
param location string

var vnetLinkSuffix = '-vlnk'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: name
}

resource privateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${last(split(virtualNetworkResourceId, '/'))}${vnetLinkSuffix}'
  location: location
  parent: privateDnsZone
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: virtualNetworkResourceId
    }
  }
}
