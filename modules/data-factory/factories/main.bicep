metadata name = 'DataFactory Module'
metadata description = 'This module deploys Microsoft.DataFactory'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. Enable managed virtual network.')
param enableManagedVirtualNetwork bool = false

@description('Optional. Enable the integration runtime inside the managed virtual network. Only required if enableManagedVirtualNetwork is true.')
param enableManagedVnetIntegrationRuntime bool = false

@description('Optional. Enable or disable public network access.')
param publicNetworkAccess bool = true

@description('Optional. Configure git during deployment.')
param configureGit bool = false

@allowed([
  'FactoryVSTSConfiguration'
  'FactoryGitHubConfiguration'
])
@description('Optional. Git repository type. Azure DevOps = FactoryVSTSConfiguration and GitHub = FactoryGitHubConfiguration.')
param gitRepoType string = 'FactoryGitHubConfiguration'

@description('Optional. Git account name. Azure DevOps = Organisation name and GitHub = Username.')
param gitAccountName string = ''

@description('Optional. Git project name. Only relevant for Azure DevOps.')
param gitProjectName string = ''

@description('Optional. Git repository name.')
param gitRepositoryName string = ''

@description('Optional. The collaboration branch name. Default is main.')
param gitCollaborationBranch string = 'main'

@description('Optional. The root folder path name. Default is /.')
param gitRootFolder string = '/'

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'AllLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Event hub name. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubName string = ''

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var managedVnetName = 'default'

var managedVnetRuntimeName = 'AutoResolveIntegrationRuntime'

var repoConfiguration = gitRepoType == 'FactoryVSTSConfiguration' ? {
  accountName: gitAccountName
  collaborationBranch: gitCollaborationBranch
  repositoryName: gitRepositoryName
  rootFolder: gitRootFolder
  type: 'FactoryVSTSConfiguration'
  projectName: gitProjectName
} : {
  accountName: gitAccountName
  collaborationBranch: gitCollaborationBranch
  repositoryName: gitRepositoryName
  rootFolder: gitRootFolder
  type: 'FactoryGitHubConfiguration'
}

var lockName = toLower('${dataFactory.name}-${resourceLock}-lck')

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var diagnosticsName = toLower('${dataFactory.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    repoConfiguration: configureGit ? repoConfiguration : null
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
  }
}

resource managedVirtualNetwork 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = if (enableManagedVirtualNetwork) {
  parent: dataFactory
  name: managedVnetName
  properties: {}
}

resource managedIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if (enableManagedVnetIntegrationRuntime) {
  parent: dataFactory
  name: managedVnetRuntimeName
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: managedVnetName
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
  dependsOn: [
    managedVirtualNetwork
  ]
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: dataFactory
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: dataFactory
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

@description('The name of the deployed data factory.')
output name string = dataFactory.name

@description('The resource ID of the deployed data factory.')
output resourceId string = dataFactory.id

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(dataFactory.identity, 'principalId') ? dataFactory.identity.principalId : ''
