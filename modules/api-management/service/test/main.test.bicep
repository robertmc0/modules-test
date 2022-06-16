@description('The location to deploy resources to')
param environment string = 'tst'

@description('The location to deploy resources to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
param companyShortName string = 'arn'

@description('Resource Tags')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${companyShortName}-tst-law-${uniqueString(deployment().name,'logAnalyticsWorkspace',location)}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${companyShortName}-tst-appi-${uniqueString(deployment().name,'appi',location)}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: '${companyShortName}-tst-kv-${uniqueString(deployment().name,'kv',location)}'
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

  resource sslCert 'secrets' = {
    name: 'sslCert'
    properties: {
      value: loadFileAsBase64('arincodeploywildcard.pfx')
      contentType:'application/x-pkcs12'
      attributes: {
        enabled: true
      }
    }
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${companyShortName}-tst-umi-${uniqueString(deployment().name,'umi',location)}'
  location: location
}

var roleDefinitionIds = [
  '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User Role
  'a4417e6f-fecd-4de8-b567-7b0420556985' // Key Vault Certificate Officer
]

resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleDefintionId in roleDefinitionIds: {
  name: guid(roleDefintionId,userIdentity.id,keyVault.id)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefintionId)
    principalId: userIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

var environmentHostingDomain = '${environment}.deploy.arinco.com.au'
var apiHostname = 'api-${environmentHostingDomain}'
var portalHostname = 'portal-api-${environmentHostingDomain}'
var managementHostname= 'management-api-${environmentHostingDomain}'

var nameValues = [
  // {
  //   displayName: 'app-gateway-public-ip'
  //   value: appGatewayPublicIp.properties.ipAddress
  // }
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

module apim '../main.bicep' = {
  name: 'deployApim'
  params: {
    name: '${companyShortName}-tst-apim-${uniqueString(deployment().name,'apim',location)}'
    location: location
    sku: 'Developer'
    skuCount: 1
    publisherEmail: 'support@arinco.com.au'
    publisherName: 'ARINCO'
    tags: tags
    diagnosticWorkspaceId: logAnalyticsWorkspace.id
    diagnosticLogsRetentionInDays: 7
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: apiHostname
        keyVaultId: keyVault::sslCert.properties.secretUri
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
      {
        type: 'DeveloperPortal'
        hostName: portalHostname
        keyVaultId: keyVault::sslCert.properties.secretUri
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
      {
        type: 'Management'
        hostName: managementHostname
        keyVaultId: keyVault::sslCert.properties.secretUri
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
    ]
    namedValues: nameValues
    applicationInsightsId: applicationInsights.id
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
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

module apim2 '../main.bicep' = {
  name: 'deployApim2'
  params: {
    name: '${companyShortName}-tst-apim2-${uniqueString(deployment().name,'apim',location)}'
    location: location
    sku: 'Developer'
    skuCount: 1
    publisherEmail: 'support@arinco.com.au'
    publisherName: 'ARINCO'
    tags: tags
    diagnosticWorkspaceId: logAnalyticsWorkspace.id
    diagnosticLogsRetentionInDays: 7
    virtualNetworkType: 'External'
    subnetResourceId: vnet.properties.subnets[0].id
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: apiHostname
        keyVaultId: keyVault::sslCert.properties.secretUri
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
      {
        type: 'DeveloperPortal'
        hostName: portalHostname
        keyVaultId: keyVault::sslCert.properties.secretUri
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
      {
        type: 'Management'
        hostName: managementHostname
        keyVaultId: keyVault::sslCert.properties.secretUri
        negotiateClientCertificate: false
        identityClientId: userIdentity.properties.clientId
      }
    ]
    namedValues: nameValues
    applicationInsightsId: applicationInsights.id
  }
}
