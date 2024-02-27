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

@description('Existing virtual network resource ID to create the dns resolver in.')
param virtualNetworkId string

@description('Optional. Existing subnet name for inbound dns requests.')
param inboundSubnetName string = 'snet-inbound'

@description('Optional. Existing subnet name for outbound dns requests.')
param outboundSubnetName string = 'snet-outbound'

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourceLock string = 'NotSpecified'

var lockName = toLower('${dnsResolver.name}-${resourceLock}-lck')

resource dnsResolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource dnsResolverInboundEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  parent: dnsResolver
  name: '${name}-dnsinbound'
  location: location
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'Dynamic'
        subnet: {
          #disable-next-line use-resource-id-functions
          id: '${virtualNetworkId}/subnets/${inboundSubnetName}'
        }
      }
    ]
  }
}

resource dnsResolverOutboundEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  parent: dnsResolver
  name: '${name}-dnsoutbound'
  location: location
  properties: {
    subnet: {
      #disable-next-line use-resource-id-functions
      id: '${virtualNetworkId}/subnets/${outboundSubnetName}'
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: dnsResolver
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed private dns resolver.')
output name string = dnsResolver.name

@description('The resource ID of the deployed private dns resolver.')
output resourceid string = dnsResolver.id

@description('The private IP Address of the deployed private dns resolver inbound endpoint.')
output inboundEndpointPrivateIpAddress string = dnsResolverInboundEndpoint.properties.ipConfigurations[0].privateIpAddress
