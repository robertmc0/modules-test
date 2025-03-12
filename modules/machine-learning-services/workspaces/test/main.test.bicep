/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('The location which test resources will be deployed to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

var tenantId = subscription().tenantId

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${shortIdentifier}tst${uniqueString(deployment().name, 'storageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${shortIdentifier}-tst-kv-${uniqueString(deployment().name, 'kv', location)}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: []
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: '${shortIdentifier}tst${uniqueString(deployment().name, 'cr', location)}'
  location: location
  sku: {
    name: 'Basic'
  }
}

resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${shortIdentifier}-tst-ai-${uniqueString(deployment().name, 'ai', location)}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
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

module machineLearningServiceWorkspaceMin '../main.bicep' = {
  name: '${shortIdentifier}-tst-${uniqueString(deployment().name, '-min-mls', location)}'
  params: {
    location: location
    name: '${shortIdentifier}-tst-${uniqueString(deployment().name, '-min-mls', location)}'
    applicationInsightsResourceId: insights.id
    keyVaultResourceId: keyVault.id
    storageAccountResourceId: storage.id
    containerRegistryResourceId: containerRegistry.id
    systemAssignedIdentity: true
  }
}

module machineLearningServiceWorkspace '../main.bicep' = {
  name: '${shortIdentifier}-tst-${uniqueString(deployment().name, 'mls', location)}'
  params: {
    location: location
    name: '${shortIdentifier}-tst-${uniqueString(deployment().name, 'mls', location)}'
    applicationInsightsResourceId: insights.id
    keyVaultResourceId: keyVault.id
    storageAccountResourceId: storage.id
    containerRegistryResourceId: containerRegistry.id
    systemAssignedIdentity: true
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
