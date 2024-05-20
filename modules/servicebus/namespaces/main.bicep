metadata name = 'Servicebus Module'
metadata description = 'This module deploys Servicebus Namespace resource.'
metadata owner = 'Arinco'

@description('Location for all Resources.')
param location string

@description('The name of the of the Servicebus Namespace.')
param name string

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param resourcelock string = 'NotSpecified'

@description('Optional. The pricing tier of this Servicebus Namespace')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Standard'

@description('Optional. The Messaging units for your service bus premium namespace.')
param capacity int = 1

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. The ID(s) to assign to the resource.')
@metadata({
  example: {
    '/subscriptions/<subscription>/resourceGroups/<rgp>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-umi': {}
  }
})
param userAssignedIdentities object = {}

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

@description('Optional. The number of partitions of a Service Bus namespace. Attribute applicable for premium servicebus.')
param premiumMessagingPartitions int = 0

@description('Optional. Diabled SAS Authentication.')
param disableLocalAuthentication bool = false

@description('Optional. Enable zone redundancy .')
param enableZoneRedundancy bool = false

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

var lockName = toLower('${servicebusNamespace.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${servicebusNamespace.name}-dgs')

var diagnosticsLogs = [
  for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
    categoryGroup: categoryGroup
    enabled: true
  }
]

var diagnosticsMetrics = [
  for metric in diagnosticMetricsToEnable: {
    category: metric
    timeGrain: null
    enabled: true
  }
]

var identityType = systemAssignedIdentity
  ? (!empty(userAssignedIdentities) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
  : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None'
  ? {
      type: identityType
      userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
    }
  : null

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    capacity: capacity
    name: sku
  }
  identity: identity
  properties: {
    disableLocalAuth: disableLocalAuthentication
    premiumMessagingPartitions: premiumMessagingPartitions
    zoneRedundant: enableZoneRedundancy
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourcelock != 'NotSpecified') {
  scope: servicebusNamespace
  name: lockName
  properties: {
    level: resourcelock
    notes: resourcelock == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: servicebusNamespace
  name: diagnosticsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticLogAnalyticsWorkspaceId) ? diagnosticLogAnalyticsWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId)
      ? diagnosticEventHubAuthorizationRuleId
      : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
    logAnalyticsDestinationType: 'Dedicated' // Means use Resource Specific named log tables
  }
}

@description('The name of the Servicebus Namespace')
output name string = servicebusNamespace.name

@description('The resource ID of the Servicebus Namespace')
output resourceId string = servicebusNamespace.id
