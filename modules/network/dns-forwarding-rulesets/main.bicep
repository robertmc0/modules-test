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

@description('Existing virtual network resource id where the private dns resolver has been deployed.')
param virtualNetworkId string

@description('Existing dns resolver outbound endpoint resource id.')
param outboundEndpointId string

@description('Define dns fowarding rules to be applied to this ruleset.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/dnsforwardingrulesets/forwardingrules?pivots=deployment-language-bicep'
  example: {
    name: 'name'
    domainName: 'domainName'
    targetDnsServers: [
      {
        ipAddress: '1.1.1.1'
        port: 53
      }
      {
        ipAddress: '1.1.1.2'
        port: 53
      }
    ]
  }
})
param dnsFwdRules array

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourceLock string = 'NotSpecified'

var lockName = toLower('${dnsFwdRuleSet.name}-${resourceLock}-lck')

resource dnsFwdRuleSet 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: outboundEndpointId
      }
    ]
  }
}

resource dnsResolverLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  parent: dnsFwdRuleSet
  name: '${name}-vnet-lnk'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource dnsFwdingRules 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01' = [for dnsFwdRule in dnsFwdRules: {
  parent: dnsFwdRuleSet
  name: dnsFwdRule.name
  properties: {
    domainName: dnsFwdRule.domainName
    targetDnsServers: dnsFwdRule.targetDnsServers
  }
}]

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: dnsFwdRuleSet
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed DNS Forwarding Ruleset.')
output name string = dnsFwdRuleSet.name

@description('The resource ID of the deployed DNS Forwarding Ruleset.')
output resourceid string = dnsFwdRuleSet.id
