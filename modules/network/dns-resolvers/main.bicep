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

@description('Existing virtual network name to create the DNS Resolver in.')
param virtualNetworkResourceName string

@description('Optional. Existing subnet name for inbound DNS requests.')
param inboundSubnetName string = 'snet-inbound'

@description('Optional. Existing subnet name for outbound DNS requests.')
param outboundSubnetName string = 'snet-outbound'

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourceLock string = 'NotSpecified'

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

var lockName = toLower('${dnsResolver.name}-${resourceLock}-lck')

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: virtualNetworkResourceName
}

resource outboundSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: vnet
  name: outboundSubnetName
}

resource inboundSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  parent: vnet
  name: inboundSubnetName
}

resource dnsResolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    virtualNetwork: {
      id: vnet.id
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
          id: inboundSubnet.id
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
      id: outboundSubnet.id
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
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
