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
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureWAFSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${shortIdentifier}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
  location: location
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: '${shortIdentifier}-tst-kv-${uniqueString(deployment().name, 'kv', location)}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
    networkAcls: {
      bypass: 'AzureServices'
    }
  }
}

var roleDefinitionIds = [
  '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User Role
  'a4417e6f-fecd-4de8-b567-7b0420556985' // Key Vault Certificate Officer
]

resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefintionId in roleDefinitionIds: {
  name: guid(roleDefintionId, userIdentity.id, keyVault.id)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefintionId)
    principalId: userIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

var environmentHostingDomain = 'deploy.arinco.local'

module kvCert 'br/public:deployment-scripts/create-kv-certificate:1.1.1' = {
  name: 'akvCertSingle'
  params: {
    akvName: keyVault.name
    location: location
    certificateName: 'deploycert'
    certificateCommonName: '*.${environmentHostingDomain}'
  }
}

module kvCaCert 'br/public:deployment-scripts/create-kv-certificate:1.1.1' = {
  name: 'akvCaCertSingle'
  params: {
    akvName: keyVault.name
    location: location
    certificateName: 'deploycacert'
    certificateCommonName: '*.ca.${environmentHostingDomain}'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
resource diagnosticsEventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsEventHubNamespace', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module appGatewayMin '../main.bicep' = {
  name: '${shortIdentifier}-tst-apgw-min-${uniqueString(deployment().name, 'applicationGateways', location)}'
  params: {
    name: '${uniqueString(deployment().name, location)}-appGateway-min'
    location: location
    sku: 'Standard_v2'
    tier: 'Standard_v2'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    publicIpAddressName: '${uniqueString(deployment().name, location)}-appGateway-min-pip'
    subnetResourceId: '${vnet.id}/subnets/AzureWAFSubnet'
    frontEndPorts: [
      {
        name: 'port_80'
        port: 80
      }
    ]
    httpListeners: [
      {
        name: 'http-80-listener'
        protocol: 'Http'
        frontEndPort: 'port_80'
      }
    ]
    backendAddressPools: [
      {
        name: 'myapp-backend-pool'
        backendAddresses: [
          {
            ipAddress: '10.1.2.3'
          }
        ]
      }
    ]
    backendHttpSettings: [
      {
        name: 'http-80-backend-settings'
        port: 80
        protocol: 'Http'
        cookieBasedAffinity: 'Enabled'
        affinityCookieName: 'MyCookieAffinityName'
        requestTimeout: 300
        connectionDraining: {
          drainTimeoutInSec: 60
          enabled: true
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myapp-http-80-rule'
        ruleType: 'Basic'
        httpListener: 'http-80-listener'
        backendAddressPool: 'myapp-backend-pool'
        backendHttpSettings: 'http-80-backend-settings'
      }
    ]
  }
}

module appGatewayNoWaf '../main.bicep' = {
  name: '${shortIdentifier}-tst-apgw-${uniqueString(deployment().name, 'applicationGateways', location)}'
  params: {
    name: '${uniqueString(deployment().name, location)}-appGateway'
    location: location
    sku: 'Standard_v2'
    tier: 'Standard_v2'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    publicIpAddressName: '${uniqueString(deployment().name, location)}-appGateway-pip'
    subnetResourceId: '${vnet.id}/subnets/AzureWAFSubnet'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    frontEndPorts: [
      {
        name: 'port_443'
        port: 443
      }
    ]
    httpListeners: [
      {
        name: 'https-443-listener'
        protocol: 'Https'
        frontEndPort: 'port_443'
        sslCertificate: environmentHostingDomain
        hostNames: [
          '*.${environmentHostingDomain}'
        ]
      }
    ]
    sslCertificates: [
      {
        name: environmentHostingDomain
        keyVaultResourceId: keyVault.id
        secretName: kvCert.outputs.certificateName
      }
    ]
    backendAddressPools: [
      {
        name: 'myapp-backend-pool'
        backendAddresses: [
          {
            ipAddress: '10.1.2.3'
          }
        ]
      }
    ]
    backendHttpSettings: [
      {
        name: 'https-443-backend-settings'
        port: 443
        protocol: 'Https'
        cookieBasedAffinity: 'Enabled'
        affinityCookieName: 'MyCookieAffinityName'
        requestTimeout: 300
        connectionDraining: {
          drainTimeoutInSec: 60
          enabled: true
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myapp-https-443-rule'
        ruleType: 'Basic'
        httpListener: 'https-443-listener'
        backendAddressPool: 'myapp-backend-pool'
        backendHttpSettings: 'https-443-backend-settings'
      }
    ]
  }
}

module appGatewayWaf '../main.bicep' = {
  name: '${shortIdentifier}-tst-apgw-waf-${uniqueString(deployment().name, 'applicationGateways', location)}'
  params: {
    name: '${uniqueString(deployment().name, location)}-appGateway-waf'
    location: location
    sku: 'WAF_v2'
    tier: 'WAF_v2'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    publicIpAddressName: '${uniqueString(deployment().name, location)}-appGateway-waf-pip'
    subnetResourceId: '${vnet.id}/subnets/AzureWAFSubnet'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    frontEndPorts: [
      {
        name: 'port_443'
        port: 443
      }
      {
        name: 'port_80'
        port: 80
      }
    ]
    probes: [
      {
        name: 'myapp-probe'
        protocol: 'https'
        host: 'myapp.deploy.arinco.local'
        pickHostNameFromBackendHttpSettings: false
        path: '/'
        interval: 30
        timeout: 30
        unhealthyThreshold: 3
        match: {
          statusCodes: [
            '200-499'
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'https-443-listener'
        protocol: 'Https'
        frontEndPort: 'port_443'
        sslCertificate: environmentHostingDomain
        hostNames: [
          '*.${environmentHostingDomain}'
        ]
        firewallPolicy: true
      }
      {
        name: 'http-80-listener'
        protocol: 'Http'
        frontEndPort: 'port_80'
      }
    ]
    sslCertificates: [
      {
        name: environmentHostingDomain
        keyVaultResourceId: keyVault.id
        secretName: kvCert.outputs.certificateName
      }
    ]
    trustedRootCertificates: [
      {
        name: 'ca${environmentHostingDomain}'
        keyVaultResourceId: keyVault.id
        secretName: kvCaCert.outputs.certificateName
      }
    ]
    backendAddressPools: [
      {
        name: 'myapp-backend-pool'
        backendAddresses: [
          {
            ipAddress: '10.1.2.3'
          }
        ]
      }
    ]
    backendHttpSettings: [
      {
        name: 'https-443-backend-settings'
        port: 443
        protocol: 'Https'
        cookieBasedAffinity: 'Enabled'
        affinityCookieName: 'MyCookieAffinityName'
        requestTimeout: 300
        connectionDraining: {
          drainTimeoutInSec: 60
          enabled: true
        }
        probeName: 'myapp-probe'
      }
      {
        name: 'https-444-backend-settings'
        port: 444
        protocol: 'Https'
        cookieBasedAffinity: 'Enabled'
        affinityCookieName: 'MyCookieAffinityName'
        requestTimeout: 300
        connectionDraining: {
          drainTimeoutInSec: 60
          enabled: true
        }
        trustedRootCertificate: 'ca${environmentHostingDomain}'
      }
      {
        name: 'http-80-backend-settings'
        port: 80
        protocol: 'Http'
        cookieBasedAffinity: 'Enabled'
        affinityCookieName: 'MyCookieAffinityName'
        requestTimeout: 300
        connectionDraining: {
          drainTimeoutInSec: 60
          enabled: true
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myapp-https-443-rule'
        ruleType: 'Basic'
        httpListener: 'https-443-listener'
        backendAddressPool: 'myapp-backend-pool'
        backendHttpSettings: 'https-443-backend-settings'
      }
      {
        name: 'myapp-http-80-rule'
        ruleType: 'Basic'
        httpListener: 'http-80-listener'
        redirectConfiguration: 'myapp-redirect-rule'
      }
    ]
    redirectConfigurations: [
      {
        name: 'myapp-redirect-rule'
        redirectType: 'Permanent'
        targetUrl: 'https://microsoft.com'
        includePath: true
        includeQueryString: true
        requestRoutingRule: 'myapp-http-80-rule'
      }
    ]
    webApplicationFirewallConfig: {
      enabled: true
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
    firewallPolicyName: '${shortIdentifier}-tst-apgw-waf-pol-${uniqueString(deployment().name, 'applicationGateways', location)}'
    firewallPolicyManagedRuleSets: [
      {
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
    ]
    firewallPolicyCustomRules: [
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
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
