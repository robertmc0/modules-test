@description('Name of the existing firewall policy.')
param firewallPolicyName string

@description('Optional. Firewall policy rules.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies/rulecollectiongroups?tabs=bicep'
  example: {
    ruleCollectionGroupName: 'string'
    priority: 'int'
    ruleCollections: [
      {
        name: 'string'
        action: {
          type: 'string'
        }
        priority: 'int'
        ruleCollectionType: 'string'
        rules: [
          {
            ruleType: 'string'
            name: 'string'
            ipProtocols: [
              'string'
            ]
            sourceAddresses: [
              'string'
            ]
            destinationAddresses: [
              'string'
            ]
            destinationPorts: [
              'string'
            ]
          }
        ]
      }
    ]
  }
})
param rules array = []

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-11-01' existing = {
  name: firewallPolicyName
}

@batchSize(1) // required to process rules serially otherwise conflicts occur with pending updates from previous operations
resource ruleCollectionGroups 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-11-01' = [for rule in rules: {
  parent: firewallPolicy
  name: rule.ruleCollectionGroupName
  properties: {
    priority: rule.priority
    ruleCollections: [for ruleCollection in rule.ruleCollections: {
      name: ruleCollection.name
      ruleCollectionType: ruleCollection.ruleCollectionType
      action: {
        type: ruleCollection.action.type
      }
      rules: map(ruleCollection.rules, r => {
          name: r.name
          ruleType: r.ruleType
          sourceIpGroups: contains(r, 'sourceIpGroups') ? map(r.sourceIpGroups, sgroup => az.resourceId('Microsoft.Network/ipGroups', sgroup)) : []
          sourceAddresses: contains(r, 'sourceAddresses') ? r.sourceAddresses : []
          destinationIpGroups: contains(r, 'destinationIpGroups') ? map(r.destinationIpGroups, dgroup => az.resourceId('Microsoft.Network/ipGroups', dgroup)) : []
          destinationAddresses: contains(r, 'destinationAddresses') ? r.destinationAddresses : []
          ipProtocols: contains(r, 'ipProtocols') ? r.ipProtocols : []
          destinationPorts: contains(r, 'destinationPorts') ? r.destinationPorts : []
          destinationFqdns: contains(r, 'destinationFqdns') ? r.destinationFqdns : []
          translatedAddress: contains(r, 'translatedAddress') ? r.translatedAddress : ''
          translatedFqdn: contains(r, 'translatedFqdn') ? r.translatedFqdn : ''
          translatedPort: contains(r, 'translatedPort') ? r.translatedPort : ''
          fqdnTags: contains(r, 'fqdnTags') ? r.fqdnTags : []
          protocols: contains(r, 'protocols') ? r.protocols : []
          targetFqdns: contains(r, 'targetFqdns') ? r.targetFqdns : []
          targetUrls: contains(r, 'targetUrls') ? r.targetUrls : []
          terminateTLS: contains(r, 'terminateTLS') ? r.terminateTLS : false
          webCategories: contains(r, 'webCategories') ? r.webCategories : []
        })
    }]
  }
}]

@description('The name of the deployed firewall policy.')
output name string = firewallPolicy.name

@description('The resource ID of the deployed firewall policy.')
output resourceId string = firewallPolicy.id
