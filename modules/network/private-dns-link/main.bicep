metadata name = 'Private DNS Zones VNET Link Module'
metadata description = 'This module deploys Microsoft.Network virtualNetworkLinks.'
metadata owner = 'Arinco'

@description('Existing virtual network resource ID(s).')
param virtualNetworkResourceId string

@description('Optional. VNET link Auto Registration.')
param registrationEnabled bool = false

@description('The Private DNS Zone name.')
param name string

@description('Optional. The location where the Private DNS Zone is deployed')
param location string

var vnetLinkSuffix = '-vlnk'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: name
}

resource privateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${last(split(virtualNetworkResourceId, '/'))}${vnetLinkSuffix}'
  location: location
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: virtualNetworkResourceId
    }
  }
}

@description('The name of the deployed private dns zone link.')
output name string = privateDnsZoneVnetLink.name

@description('The resource ID of the deployed private dns zone link.')
output resourceId string = privateDnsZoneVnetLink.id
