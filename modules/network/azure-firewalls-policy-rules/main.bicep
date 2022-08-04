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

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01' existing = {
  name: firewallPolicyName
}

@batchSize(1) // required to process rules serially otherwise conflicts occur with pending updates from previous operations
resource ruleCollectionGroups 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = [for rule in rules: {
  parent: firewallPolicy

  name: rule.ruleCollectionGroupName
  properties: {
    priority: rule.priority
    ruleCollections: rule.ruleCollections
  }
}]

@description('The name of the deployed firewall policy.')
output name string = firewallPolicy.name

@description('The resource ID of the deployed firewall policy.')
output resourceId string = firewallPolicy.id
