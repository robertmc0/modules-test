/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/
var environmentHostingDomain = 'deploy.arinco.local'

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: environmentHostingDomain
  location: 'global'
}

resource wafPolicy 'Microsoft.Network/frontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: 'wafPolicy1'
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

resource wafPolicy2 'Microsoft.Network/frontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: 'wafPolicy2'
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      mode: 'Prevention'
    }
  }
}

var frontDoorName = 'frontdoor-min'

resource profile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: frontDoorName
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

module frontDoorAppMinimum '../main.bicep' = {
  // dependsOn: [
  //   keyVaultRoleAssignment
  // ]
  name: 'frontdoor-app-min-module'
  params: {
    profileName: frontDoorName
    // secrets: [
    //   {
    //     parameters: {
    //       certificateSecretId: secret.id
    //     }
    //     secretName: 'secret1'
    //   }
    // ]
    customDomains: [
      {
        customDomainName: 'customDomain1'
        dnsZoneId: dnsZone.id
        hostName: environmentHostingDomain
        tlsSettings: {
          certificateType: 'ManagedCertificate'
          minimumTlsVersion: 'TLS12'
          //secretName: 'secret1'
        }
        policy: 'policy1'
      }
    ]
    endpoints: [
      {
        name: 'endpoint1'
        policy: 'policy1'
      }
      {
        name: 'endpoint2'
        enabledState: 'Enabled'
        policy: 'policy2'
      }
    ]
    originGroups: [
      {
        name: 'og1'
      }
    ]
    origins: [
      {
        hostName: 'deploy.arinco.local'
        originGroupName: 'og1'
        originHostHeader: 'deploy.arinco.local'
        originName: 'o1'
      }
    ]
    routes: [
      {
        customDomains: [
          {
            name: 'customDomain1'
          }
        ]
        endpointName: 'endpoint1'
        originGroupName: 'og1'
        routeName: 'route1'
        forwardingProtocol: 'HttpsOnly'
        cacheConfiguration: {
          compressionSettings: {
            isCompressionEnabled: true
            contentTypesToCompress: [
              'Image/jpeg'
            ]
          }
          queryStringCachingBehavior: 'IgnoreQueryString'
        }
        // ruleSets: [
        //   {
        //     id: ruleSet.id
        //   }
        // ]
      }
    ]
    securityPolicies: [
      {
        name: 'policy1'
        wafPolicyId: wafPolicy.id
        patternsToMatch: [ '/*' ]
      }
      {
        name: 'policy2'
        wafPolicyId: wafPolicy2.id
      }
    ]
  }
}
