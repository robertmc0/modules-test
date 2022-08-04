/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01' = {
  name: '${shortIdentifier}-tst-afwp-${uniqueString(deployment().name, 'firewallPolicies', location)}'
  location: location
  properties: {
  }
}
/*======================================================================
TEST EXECUTION
======================================================================*/
module rules '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-rules'
  params: {
    firewallPolicyName: firewallPolicy.name
    rules: [
      {
        ruleCollectionGroupName: 'DefaultDnatRuleCollectionGroup'
        priority: 100
        ruleCollections: [
          {
            name: 'dnat-rules'
            action: {
              type: 'Dnat'
            }
            priority: 100
            ruleCollectionType: 'FirewallPolicyNatRuleCollection'
            rules: [
              {
                ruleType: 'NatRule'
                name: 'dnat1'
                translatedAddress: '10.1.2.3'
                translatedPort: '8080'
                ipProtocols: [
                  'TCP'
                ]
                sourceAddresses: [
                  '*'
                ]
                destinationAddresses: [
                  '10.1.2.3'
                ]
                destinationPorts: [
                  '80'
                ]
              }
            ]
          }
        ]
      }
      {
        ruleCollectionGroupName: 'DefaultNetworkRuleCollectionGroup'
        priority: 200
        ruleCollections: [
          {
            name: 'network-rules'
            action: {
              type: 'Allow'
            }
            priority: 200
            ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
            rules: [
              {
                ruleType: 'NetworkRule'
                name: 'net1'
                ipProtocols: [
                  'Any'
                ]
                sourceAddresses: [
                  '*'
                ]
                destinationAddresses: [
                  'AzureCloud'
                ]
                destinationPorts: [
                  '*'
                ]
              }
            ]
          }
        ]
      }
      {
        ruleCollectionGroupName: 'DefaultApplicationRuleCollectionGroup'
        priority: 300
        ruleCollections: [
          {
            name: 'app-rules'
            action: {
              type: 'Allow'
            }
            priority: 300
            ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
            rules: [
              {
                ruleType: 'ApplicationRule'
                name: 'app1'
                protocols: [
                  {
                    protocolType: 'Http'
                    port: 80
                  }
                ]
                targetFqdns: [
                  '*.microsoft.com'
                ]
                sourceAddresses: [
                  '*'
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}
