@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. Local network gateway BGP speaker settings.')
@metadata({
  asn: 'Integer containing the BGP speaker ASN.'
  bgpPeeringAddress: 'The BGP peering address and BGP identifier of this BGP speaker.'
  bgpPeeringAddresses: [
    {
      customBgpIpAddresses: [
        'The list of custom BGP peering addresses which belong to IP configuration.'
      ]
      ipconfigurationId: 'The ID of IP configuration which belongs to gateway.'
    }
  ]
  peerWeight: 'Integer containing the weight added to routes learned from this BGP speaker.'
})
param bgpSettings object = {}

@description('A list of address blocks reserved for this virtual network in CIDR notation.')
param addressPrefixes array = []

@description('The endpoint type of the local network gateway.')
@allowed([
  'fqdn'
  'ipAddress'
])
param endpointType string

@description('The endpoint of the local network gateway. Either FQDN or IpAddress.')
@metadata({
  fqdn: 'FQDN of local network gateway'
  ipAddress: 'IP address of local network gateway.'
})
param endpoint string

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourceLock string = 'NotSpecified'

var lockName = toLower('${localNetworkGateway.name}-${resourceLock}-lck')

resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2022-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    bgpSettings: bgpSettings
    fqdn: endpointType == 'fqdn' ? endpoint : null
    gatewayIpAddress: endpointType == 'ipAddress' ? endpoint : null
    localNetworkAddressSpace: {
      addressPrefixes: addressPrefixes
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: localNetworkGateway
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed local network gateway.')
output name string = localNetworkGateway.name

@description('The resource ID of the deployed local network gateway.')
output resourceId string = localNetworkGateway.id
