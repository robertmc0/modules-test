metadata name = 'Operational Insights Workspace Module.'
metadata description = 'This module deploys Microsoft.OperationalInsights workspaces, aka Log Analytics workspaces.'
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

@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
@description('Optional. The SKU of the workspace.')
param sku string = 'PerGB2018'

@description('Optional. The workspace data retention in days. Allowed values are per pricing plan. See pricing tiers documentation for details.')
@minValue(7)
@maxValue(730)
param retentionInDays int = 365

@description('Optional. Solutions to add to workspace.')
@metadata({
  name: 'Solution name.'
  product: 'Product name, e.g. OMSGallery/AzureActivity.'
  publisher: 'Publisher name.'
  promotionCode: 'Promotion code if applicable.'
})
param solutions array = []

@description('Optional. Resource id of automation account to link to workspace.')
param automationAccountId string = ''

@description('Optional. Datasources to add to workspace.')
@metadata({
  name: 'Data source name.'
  kind: 'Data source kind.'
  properties: 'The data source properties in raw json format, each kind of data source have its own schema.'
})
param dataSources array = []

@description('Optional. Saved searches to add to workspace.')
@metadata({
  name: 'Saved search name.'
  category: 'The category of the saved search.'
  displayName: 'Saved search display name.'
  query: 'The query expression for the saved search.'
  functionAlias: 'The function alias if query serves as a function.'
  functionParameters: 'The optional function parameters if query serves as a function.'
})
param savedSearches array = []

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourcelock string = 'NotSpecified'

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'Audit'
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'Audit'
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

var lockName = toLower('${logAnalyticsWorkspace.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${logAnalyticsWorkspace.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

resource logAnalyticsSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution.name}(${logAnalyticsWorkspace.name})'
  location: location
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: '${solution.name}(${logAnalyticsWorkspace.name})'
    product: solution.product
    publisher: solution.publisher
    promotionCode: solution.promotionCode
  }
}]

resource logAnalyticsAutomation 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = if (!empty(automationAccountId)) {
  #disable-next-line use-parent-property
  name: '${logAnalyticsWorkspace.name}/Automation'
  properties: {
    resourceId: automationAccountId
  }
}

resource logAnalyticsDataSource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [for dataSource in dataSources: {
  #disable-next-line use-parent-property
  name: '${logAnalyticsWorkspace.name}/${dataSource.name}'
  kind: dataSource.kind
  properties: dataSource.properties
}]

resource logAnalyticsSavedSearch 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = [for savedSearch in savedSearches: {
  parent: logAnalyticsWorkspace
  name: savedSearch.name
  properties: {
    category: savedSearch.category
    displayName: savedSearch.displayName
    functionAlias: contains(savedSearch, 'functionAlias') ? savedSearch.functionAlias : null
    functionParameters: contains(savedSearch, 'functionParameters') ? savedSearch.functionParameters : null
    query: savedSearch.query
    version: contains(savedSearch, 'version') ? savedSearch.version : 2
  }
}]

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: logAnalyticsWorkspace
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: logAnalyticsWorkspace
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

@description('The name of the deployed log analytics workspace.')
output name string = logAnalyticsWorkspace.name

@description('The resource ID of the deployed log analytics workspace.')
output resourceId string = logAnalyticsWorkspace.id
