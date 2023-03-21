/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The location to deploy resources to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
@minLength(1)
@maxLength(3)
param companyShortName string = 'arn'

//var environmentHostingDomain = 'deploy.arinco.local'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${companyShortName}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
//   name: '${companyShortName}-tst-kv-${uniqueString(deployment().name, 'kv', location)}'
//   location: location
//   properties: {
//     sku: {
//       family: 'A'
//       name: 'standard'
//     }
//     tenantId: subscription().tenantId
//     enableRbacAuthorization: true
//     enabledForTemplateDeployment: true
//     networkAcls: {
//       bypass: 'AzureServices'
//     }
//   }
// }

// resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
//   name: environmentHostingDomain
//   location: 'global'
// }

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${companyShortName}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
  location: location
}

// var roleDefinitionIds = [
//   '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User Role
//   'a4417e6f-fecd-4de8-b567-7b0420556985' // Key Vault Certificate Officer
// ]

// resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefintionId in roleDefinitionIds: {
//   name: guid(roleDefintionId, userIdentity.id, keyVault.id)
//   scope: keyVault
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefintionId)
//     principalId: userIdentity.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }]

// module kvCert 'br/public:deployment-scripts/create-kv-certificate:1.1.1' = {
//   name: 'akvCertSingle'
//   params: {
//     akvName: keyVault.name
//     location: location
//     certificateName: 'deploycert'
//     certificateCommonName: '*.${environmentHostingDomain}'
//   }
// }

// resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' existing = {
//   parent: keyVault
//   name: 'deploycert'
// }

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

// resource ruleSet 'Microsoft.Cdn/profiles/ruleSets@2022-11-01-preview' = {
//   name: '${frontDoorName}/MaintenancePageRedirects'
//   //parent: profile

//   resource rule 'rules@2022-11-01-preview' = {
//     name: 'MaintenancePageRedirectForExternal'
//     properties: {
//       order: 1
//       matchProcessingBehavior: 'Stop'
//       actions: [
//         {
//           name: 'UrlRedirect'
//           parameters: {
//             redirectType: 'TemporaryRedirect'
//             destinationProtocol: 'Https'
//             customHostname: 'maintenance.racgp.org.au'
//             typeName: 'DeliveryRuleUrlRedirectActionParameters'
//           }
//         }
//       ]
//       conditions: [
//         {
//           name: 'RemoteAddress'
//           parameters: {
//             operator: 'IPMatch'
//             typeName: 'DeliveryRuleRemoteAddressConditionParameters'
//             matchValues: [
//               '203.8.200.20'
//             ]
//             negateCondition: true
//           }
//         }
//       ]
//     }
//   }
// }

/*======================================================================
TEST EXECUTION
======================================================================*/
var frontDoorName = 'frontdoor-min'
module frontDoorMinimum '../main.bicep' = {
  // dependsOn: [
  //   keyVaultRoleAssignment
  // ]
  name: 'frontdoor-min-module'
  params: {
    // secrets: [
    //   {
    //     parameters: {
    //       certificateSecretId: secret.id
    //     }
    //     secretName: 'secret1'
    //   }
    // ]
    // customDomains: [
    //   {
    //     customDomainName: 'customDomain1'
    //     dnsZoneId: dnsZone.id
    //     hostName: environmentHostingDomain
    //     tlsSettings: {
    //       certificateType: 'ManagedCertificate'
    //       minimumTlsVersion: 'TLS12'
    //       //secretName: 'secret1'
    //     }
    //     policy: 'policy1'
    //   }
    // ]
    // endpoints: [
    //   {
    //     name: 'endpoint1'
    //     policy: 'policy1'
    //   }
    //   {
    //     name: 'endpoint2'
    //     enabledState: 'Enabled'
    //     policy: 'policy2'
    //   }
    // ]
    name: frontDoorName
    // originGroups: [
    //   {
    //     name: 'og1'
    //   }
    // ]
    // origins: [
    //   {
    //     hostName: 'deploy.arinco.local'
    //     originGroupName: 'og1'
    //     originHostHeader: 'deploy.arinco.local'
    //     originName: 'o1'
    //   }
    // ]
    // routes: [
    //   {
    //     customDomains: [
    //       {
    //         name: 'customDomain1'
    //       }
    //     ]
    //     endpointName: 'endpoint1'
    //     originGroupName: 'og1'
    //     routeName: 'route1'
    //     forwardingProtocol: 'HttpsOnly'
    //     // ruleSets: [
    //     //   {
    //     //     id: ruleSet.id
    //     //   }
    //     // ]
    //   }
    // ]
    // securityPolicies: [
    //   {
    //     name: 'policy1'
    //     wafPolicyId: wafPolicy.id
    //     patternsToMatch: [ '/*' ]
    //   }
    //   {
    //     name: 'policy2'
    //     wafPolicyId: wafPolicy2.id
    //   }
    // ]
    skuName: 'Standard_AzureFrontDoor'
    resourceLock: 'CanNotDelete'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
}

// resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' existing = {
//   name: 'frontdoor-min/endpoint1'
// }

// resource endpoint2 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' existing = {
//   name: 'frontdoor-min/endpoint2'
// }

// var endpointIds = [
//   endpoint.id
//   endpoint2.id
// ]

// module securityPolicy '../securityPolicy.bicep' = {
//   name: 'securityPolicy'
//   params: {
//     endpoints: frontDoorMinimum.outputs.endpoints
//     customDomains: frontDoorMinimum.outputs.customDomains
//     wafPolicyId: wafPolicy.id
//     policyName: 'policy1'
//     profileName: frontDoorName
//   }
// }

//output endpoints array = frontDoorMinimum.outputs.endpoints

// resource policy 'Microsoft.Cdn/profiles/securityPolicies@2022-11-01-preview' = {
//   name: 'frontdoor-min/policy1'
//   //parent: profile
//   properties: {
//     parameters: {
//       type: 'WebApplicationFirewall'
//       associations: [
//         {
//           patternsToMatch: [
//             '/*'
//           ]
//           domains: [for id in frontDoorMinimum.outputs.endpointIds: {
//             #disable-next-line use-resource-id-functions
//             id: id
//           }]
//         }
//       ]
//       wafPolicy: {
//         id: wafPolicy.id
//       }
//     }
//   }
// }

// resource policy 'Microsoft.Cdn/profiles/securityPolicies@2022-11-01-preview' = {
//   name: 'frontdoor-min/policy1'
//   //parent: profile
//   dependsOn: [
//     frontDoorMinimum
//   ]
//   properties: {
//     parameters: {
//       type: 'WebApplicationFirewall'
//       associations: [
//         {
//           //patternsToMatch: a.patternsToMatch
//           domains: [for d in x: {
//             id: az.resourceId('Microsoft.Network/applicationGateways/probes', d.name)
//           }]
//         }
//       ]
//       // associations2: [
//       //   {
//       //     domains: [
//       //       {
//       //         id:'id'
//       //       }
//       //     ]
//       //     patternsToMatch: [
//       //       'a'
//       //       'b'
//       //     ]
//       //   }
//       // ]
//       wafPolicy: {
//         id: wafPolicy.id
//       }
//     }
//   }
// }
