/*======================================================================
TEST PREREQUISITES
======================================================================*/
var environmentHostingDomain = 'deploy.arinco.com.au'

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: environmentHostingDomain
  location: 'global'
}

resource wafNpdPolicy 'Microsoft.Network/frontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: 'wafPolicynpdapp'
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      mode: 'Detection'
    }
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/

var uniqueName = uniqueString(deployment().name, 'global')

resource profileMin 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: '${uniqueName}-min-afd'
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

module frontDoorEndpointsMin '../main.bicep' = {
  name: 'frontdoor-endpoints-min-deploy'
  params: {
    profileName: profileMin.name
    endpoints: [
      {
        name: 'dev-endpoint'
      }
    ]
    originGroups: [
      {
        name: 'dev-origin-group'
      }
    ]
    origins: [
      {
        originGroupName: 'dev-origin-group'
        originHostHeader: '1.1.1.1' // or HOST header value
        originName: 'dev-origin'
        hostName: 'dev.deploy.arinco.local'
      }
    ]
    routes: [
      {
        routeName: 'dev-route'
        endpointName: 'dev-endpoint'
        originGroupName: 'dev-origin-group'
      }
    ]
  }
}

resource profileStd 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: '${uniqueName}-std-afd'
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

module frontDoorEndpointsStd '../main.bicep' = {
  name: 'frontdoor-endpoints-std-deploy'
  params: {
    profileName: profileStd.name
    customDomains: [
      {
        customDomainName: 'dev-domain'
        dnsZoneId: dnsZone.id
        hostName: 'dev.${environmentHostingDomain}'
        tlsSettings: {
          certificateType: 'ManagedCertificate'
          minimumTlsVersion: 'TLS12'
        }
      }
      {
        customDomainName: 'stg-domain'
        dnsZoneId: dnsZone.id
        hostName: 'stg.${environmentHostingDomain}'
        tlsSettings: {
          certificateType: 'ManagedCertificate'
          minimumTlsVersion: 'TLS12'
        }
      }
    ]
    endpoints: [
      {
        name: 'dev-app-endpoint'
      }
      {
        name: 'stg-app-endpoint'
      }
    ]
    originGroups: [
      {
        name: 'dev-origin-group'
        loadBalancingSettings: {
          sampleSize: 5
          successfulSamplesRequired: 2
        }
      }
      {
        name: 'stg-origin-group'
        loadBalancingSettings: {
          sampleSize: 10
          successfulSamplesRequired: 4
        }
      }
    ]
    origins: [
      {
        originGroupName: 'dev-origin-group'
        originName: 'dev-app-aus-southeast'
        hostName: 'dev-app-ause.azurewebsites.net'
        weight: 20
        priority: 2
      }
      {
        originGroupName: 'dev-origin-group'
        originName: 'dev-app-aus-east'
        hostName: 'dev-app-aue.azurewebsites.net'
        weight: 10
        priority: 1
      }
      {
        originGroupName: 'stg-origin-group'
        originName: 'stg-app-aus-southeast'
        hostName: 'stg-app-ause.azurewebsites.net'
        weight: 20
        priority: 2
      }
      {
        originGroupName: 'stg-origin-group'
        originName: 'stg-app-aus-east'
        hostName: 'stg-app-aue.azurewebsites.net'
        weight: 10
        priority: 1
      }
    ]
    ruleSets: [
      {
        ruleSetName: 'MaintenancePageRuleSet'
        rules: [
          {
            ruleName: 'MaintenancePageRedirectForExternal'
            actions: [
              {
                name: 'UrlRedirect'
                parameters: {
                  redirectType: 'TemporaryRedirect'
                  typeName: 'DeliveryRuleUrlRedirectActionParameters'
                  destinationProtocol: 'Https'
                }
              }
            ]
            conditions: [
              {
                name: 'RemoteAddress'
                parameters: {
                  operator: 'IPMatch'
                  typeName: 'DeliveryRuleRemoteAddressConditionParameters'
                  negateCondition: true
                  matchValues: [
                    '172.100.2.0/23'
                  ]
                  transforms: []
                }
              }
            ]
            matchProcessingBehavior: 'Stop'
            order: 10
          }
        ]
      }
    ]
    routes: [
      {

        endpointName: 'dev-app-endpoint'
        originGroupName: 'dev-origin-group'
        routeName: 'dev-route'
        customDomains: [
          {
            name: 'dev-domain'
          }
        ]
        forwardingProtocol: 'HttpsOnly'
        rulesets: [
          {
            name: 'MaintenancePageRuleSet'
          }
        ]
      }
      {

        endpointName: 'stg-app-endpoint'
        originGroupName: 'stg-origin-group'
        routeName: 'stg-route'
        customDomains: [
          {
            name: 'stg-domain'
          }
        ]
        forwardingProtocol: 'HttpsOnly'
        rulesets: [
          {
            name: 'MaintenancePageRuleSet'
          }
        ]
      }
    ]
    securityPolicies: [
      {
        policyName: 'npd-app-security-policy'
        firewallPolicyId: wafNpdPolicy.id
        customDomains: [
          {
            name: 'dev-domain'
          }
          {
            name: 'stg-domain'
          }
        ]
        endpoints: [
          {
            name: 'dev-app-endpoint'
          }
          {
            name: 'stg-app-endpoint'
          }
        ]
      }
    ]
  }
}

output endpoints array = frontDoorEndpointsStd.outputs.endpoints
output customDomainValidations array = frontDoorEndpointsStd.outputs.customDomainValidations
