/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The environment')
param environment string = 'tst'

@description('Optional. The location to deploy resources to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
@minLength(1)
@maxLength(3)
param companyShortName string = 'arn'

@description('Optional. The type of VPN in which API Management service needs to be configured in. None (Default Value) means the API Management service is not part of any Virtual Network, External means the API Management deployment is set up inside a Virtual Network having an internet Facing Endpoint, and Internal means that API Management deployment is setup inside a Virtual Network having an Intranet Facing Endpoint only.')
@allowed([
  'None'
  'External'
  'Internal'
])
param virtualNetworkType string = 'External'

@description('Resource Tags')
param tags object = {}

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

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${companyShortName}-tst-appi-${uniqueString(deployment().name, 'appi', location)}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = if (virtualNetworkType != 'None') {
  name: 'arinco-appcore-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'apim-subnet'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
    ]
  }
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: 'arinco-apim-public-ip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: 'arinnco-apim-public-ip-address'
    }
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${companyShortName}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
  location: location
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: '${companyShortName}-tst-kv-${uniqueString(deployment().name, 'kv', location)}'
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
var apiHostname = 'api-${environment}.${environmentHostingDomain}'
var portalHostname = 'portal-api-${environment}.${environmentHostingDomain}'
var managementHostname = 'management-api-${environment}.${environmentHostingDomain}'

module kvCert 'br/public:deployment-scripts/create-kv-certificate:1.1.1' = {
  name: 'akvCertSingle'
  params: {
    akvName: keyVault.name
    location: location
    certificateName: 'deploycert'
    certificateCommonName: '*.${environmentHostingDomain}'
  }
}
var sslCertSecretId = kvCert.outputs.certificateSecretIdUnversioned

var nameValues = [
  {
    displayName: 'api-management-subscription-id'
    value: subscription().subscriptionId
  }
  {
    displayName: 'api-management-resource-group-name'
    value: resourceGroup().name
  }
  {
    displayName: 'api-management-portal-host-name'
    value: portalHostname
  }
]

/*======================================================================
TEST EXECUTION
======================================================================*/
module apim '../main.bicep' = {
  name: 'deployApim'
  params: {
    name: '${companyShortName}-tst-apim-${uniqueString(deployment().name, 'apim', location)}'
    location: location
    sku: 'Developer'
    skuCount: 1
    publisherEmail: 'support@arinco.com.au'
    publisherName: 'ARINCO'
    tags: tags
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticLogsRetentionInDays: 7
    virtualNetworkType: virtualNetworkType
    publicIpAddressId: publicIpAddress.id
    subnetResourceId: virtualNetworkType != 'None' ? vnet.properties.subnets[0].id : ''
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: apiHostname
        keyVaultId: sslCertSecretId
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
      {
        type: 'DeveloperPortal'
        hostName: portalHostname
        keyVaultId: sslCertSecretId
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
      {
        type: 'Management'
        hostName: managementHostname
        keyVaultId: sslCertSecretId
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
    ]
    namedValues: nameValues
    applicationInsightsId: applicationInsights.id
  }
  dependsOn: [
    keyVaultRoleAssignment
  ]
}
