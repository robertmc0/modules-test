/*======================================================================
TEST EXECUTION
======================================================================*/
var location = 'global'

module firewallPolicyMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}minfirewallpolicy'
  params: {
    name: '${uniqueString(deployment().name, location)}minpol'
    skuName: 'Standard_AzureFrontDoor'
  }
}

module firewallPolicyStdCustomRules '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}stdfirewallpolicy'
  params: {
    name: '${uniqueString(deployment().name, location)}stdpol'
    skuName: 'Standard_AzureFrontDoor'
    customRules: {
      rules: [
        {
          action: 'Allow'
          matchConditions: [
            {
              matchValue: [
                '172.1.15.2/24'
              ]
              negateCondition: false
              transforms: []
              matchVariable: 'RemoteAddr'
              operator: 'IPMatch'
            }
          ]
          priority: 10
          ruleType: 'MatchRule'
          enabledState: 'Enabled'
          name: 'ipwhitelist'
        }
      ]
    }
    policySettings: {
      requestBodyCheck: 'Enabled'
      enabledState: 'Enabled'
      mode: 'Prevention'
    }
    resourceLock: 'CanNotDelete'
  }
}

module firewallPolicyWithManagedRules '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}premfirewallpolicy'
  params: {
    name: '${uniqueString(deployment().name, location)}prempol'
    skuName: 'Premium_AzureFrontDoor'
    customRules: {
      rules: [
        {
          action: 'Allow'
          matchConditions: [
            {
              matchValue: [
                '172.1.15.2/24'
              ]
              negateCondition: false
              transforms: []
              matchVariable: 'RemoteAddr'
              operator: 'IPMatch'
            }
          ]
          priority: 10
          ruleType: 'MatchRule'
          enabledState: 'Enabled'
          name: 'ipwhitelist'
        }
      ]
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.0'
          ruleSetAction: 'Block'
          exclusions: [
            {
              matchVariable: 'RequestHeaderNames'
              selector: 'someheader'
              selectorMatchOperator: 'Contains'
            }
          ]
          ruleGroupOverrides: [
            {
              ruleGroupName: 'PROTOCOL-ATTACK'
              exclusions: [
                {
                  matchVariable: 'RequestHeaderNames'
                  selector: 'string'
                  selectorMatchOperator: 'Contains'
                }
              ]
              rules: [
                {
                  ruleId: '921140'
                  enabledState: 'Enabled'
                  exclusions: [
                    {
                      matchVariable: 'RequestHeaderNames'
                      selector: 'anotherheader'
                      selectorMatchOperator: 'Contains'
                    }
                  ]
                }
              ]
            }
          ]
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.0'
        }
      ]
    }
    policySettings: {
      requestBodyCheck: 'Enabled'
      enabledState: 'Enabled'
      mode: 'Prevention'
    }
    resourceLock: 'CanNotDelete'
  }
}
