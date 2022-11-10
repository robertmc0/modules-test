/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. Deploy minimum registry configuration. True: minimum configuration, False: maximum configuration.')
param deployMinimum bool = true

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('ID of RBAC role definition, see https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for guids')
param roleDefinitionIds array = [
  // 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // reader
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // contributor
  // '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' // owner
]

@description('The JsonWebKeyType of the key to be created.')
@allowed([
  'EC'
  'EC-HSM'
  'RSA'
  'RSA-HSM'
])
param keyType string = 'RSA'

/*======================================================================
TEST PREREQUISITES
======================================================================*/

var rbacAssignments = [for roleDefinitionId in roleDefinitionIds: {
  name: guid(managedIdentity.id, resourceGroup().id, roleDefinitionId)
  roleDefinitionId: roleDefinitionId
}]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: '${shortIdentifier}-tst-uai-${uniqueString(deployment().name, 'userAssignedManagedIdentity', location)}'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for rbacAssignment in rbacAssignments: {
  name: rbacAssignment.name
  scope: resourceGroup()
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', rbacAssignment.roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}]

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

resource keyVault  'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${shortIdentifier}-tst-kv-${uniqueString(deployment().name, 'keyVault5', location)}'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 30
    enablePurgeProtection: true
    accessPolicies: [
      {
        objectId: managedIdentity.properties.principalId
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'encrypt'
            'decrypt'
            'unwrapKey'
            'wrapKey'
            'get'
          ]
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  parent: keyVault
  name: '${shortIdentifier}-tst-key-${uniqueString(deployment().name, 'keyVault5', location)}'
  properties: {
    kty: keyType
    keyOps: []
    keySize: 2048
    curveName: ''
  }
}



/*======================================================================
TEST EXECUTION
======================================================================*/

module registryMinimum '../main.bicep' = if (deployMinimum == true) {
  name: '${uniqueString(deployment().name, location)}-min-acr'
  params: {
    name: '${shortIdentifier}acrmin${uniqueString(deployment().name, 'min', location)}'
    location: location
    enableDiagnostics: true
    sku: 'Standard'
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
  }
}

module registryMaximum '../main.bicep' = if (deployMinimum == false) {
  name: '${uniqueString(deployment().name, location)}-max-acr'
  params: {
    name: '${shortIdentifier}acrmax${uniqueString(deployment().name, 'max', location)}'
    location: location
    enableDiagnostics: true
    sku: 'Premium'
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    encryptionEnabled: true
    userAssignedIdentity: managedIdentity.id
    userAssignedIdentityId: managedIdentity.properties.clientId
    keyVaultIdentifier: key.properties.keyUri
    dataEndpointEnabled: true
    zoneRedundancy: true
    disablePublicNetworkAccess: true
    allowNetworkRuleBypass: true
    allowedIpRanges:[
      '119.17.149.9'
      '119.17.149.10'
    ]
    resourceLock: 'CanNotDelete'
  }
}
