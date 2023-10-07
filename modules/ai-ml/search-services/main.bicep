metadata name = 'Azure Search Service'
metadata description = 'Deploys Azure Search Service Account.'
metadata owner = 'Arinco'

@description('The name of the Search Service Account.')
param name string

@description('Optional. The location of the Cognitive Service Account.')
param location string = resourceGroup().location

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

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

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param resourcelock string = 'NotSpecified'

var lockName = toLower('${account.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${account.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

resource account 'Microsoft.Search/searchServices@2020-08-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: account
  name: diagnosticsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticLogAnalyticsWorkspaceId) ? diagnosticLogAnalyticsWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourcelock != 'NotSpecified') {
  scope: account
  name: lockName
  properties: {
    level: resourcelock
    notes: resourcelock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The endpoint (subdomain) of the deployed Cognitive Service.')
output endpoint string = account.properties.endpoint
@description('The resource ID of the deployed Cognitive Service.')
output id string = account.id
@description('The name of the deployed Cognitive Service.')
output name string = account.name
