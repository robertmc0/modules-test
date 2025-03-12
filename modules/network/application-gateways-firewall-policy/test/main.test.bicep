/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

/*======================================================================
TEST EXECUTION
======================================================================*/
module firewallPolicyMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-firewall-policy'
  params: {
    name: '${uniqueString(deployment().name, location)}-min-pol'
    location: location
  }
}

module firewallPolicy '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-firewall-policy'
  params: {
    name: '${uniqueString(deployment().name, location)}-pol'
    location: location
    customRules: [
      {
        name: 'myapp-block-ip-rule'
        priority: 100
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchValues: [
              '172.70.0.1'
            ]
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
          }
        ]
      }
    ]
    managedRuleExclusions: [
      {
        matchVariable: 'RequestHeaderNames'
        selectorMatchOperator: 'StartsWith'
        selector: 'myapp1'
      }
    ]
    managedRuleSets: [
      {
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
    ]
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
    }
    resourceLock: 'CanNotDelete'
  }
}
