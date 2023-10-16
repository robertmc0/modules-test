metadata name = 'Azure Search Service'
metadata description = 'Deploys Azure Search Service Account.'
metadata owner = 'Arinco'

@description('The name of the Search Service Account.')
param name string

@description('Optional. The location of the Search Service Account.')
param location string = resourceGroup().location

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. The Sku of the Search Service Account.')
@allowed([
  'basic'
  'free'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param sku string = 'standard'

@description('Optional. The hosting mode of the Search Service Account. highDensity is only available for standard3 SKUs.')
@allowed([
  'default'
  'highDensity'
])
param hostingMode string = 'default'

@description('Optional. The number of replicas in the Search Service Account.  If specified, it must be a value between 1 and 12 inclusive for standard SKUs or between 1 and 3 inclusive for basic SKU.')
@metadata(
  { guidance: 'https://learn.microsoft.com/en-us/azure/search/search-capacity-planning' }
)
@allowed([
  1
  2
  3
  4
  5
  6
  7
  8
  9
  10
  11
  12
])
param replicaCount int = 1

@description('Optional. The number of partitions in the Search Service Account. Values greater than 1 are only valid for standard SKUs. For standard3 services with hostingMode set to highDensity, the allowed values are between 1 and 3.')
@metadata(
  { guidance: 'https://learn.microsoft.com/en-us/azure/search/search-capacity-planning' }
)
@allowed([
  1
  2
  3
  4
  6
  12
])
param partitionCount int = 1

@description('Optional. Enable/Disable semantic search.')
@allowed([
  'disabled'
  'free'
  'standard'
])
param semanticSearch string = 'disabled'

@description('Optional. Enable/Disable public acccess.')
@allowed([
  'enabled'
  'disabled'
])
param publicNetworkAccess string = 'enabled'

@description('Optional. The auth options of the Search Service Account.')
@metadata({
  example: {
    aadOrApiKey: {
      aadAuthFailureMode: 'http401WithBearerChallenge or http403'
    }
    apiKeyOnly: 'any()'
  }
})
param authOptions object = {
  aadOrApiKey: {
    aadAuthFailureMode: 'http403'
  }
}

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
@metadata({
  example: {
    '/subscriptions/<subscription>/resourceGroups/<rgp>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-umi': {}
  }
})
param userAssignedIdentities object = {}

@description('Optional. The data exfiltration options for the Search Service Account. Currently not able to be modified, param added for future service update.')
@allowed([
  'All'
])
param disabledDataExfiltrationOptions string = 'All'

@description('Optional. Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed.')
param allowedIpRanges array = []

@description('Optional. The default action of allow or deny when no other rules match.')
@allowed([
  'Allow'
  'Deny'
])
param networkRuleSetDefaultAction string = 'Deny'

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

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

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

var ipRulesAllowedIpRanges = [for ip in allowedIpRanges: {
  value: ip
  action: 'Allow'
}]

resource account 'Microsoft.Search/searchServices@2021-04-01-preview' = {//note that most up to date API version does not support semantic search :(
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  identity: identity
  properties: {
    authOptions: authOptions
    disabledDataExfiltrationOptions: [ disabledDataExfiltrationOptions ]
    partitionCount: partitionCount
    replicaCount: replicaCount
    hostingMode: hostingMode
    semanticSearch: semanticSearch
    publicNetworkAccess: publicNetworkAccess
    networkRuleSet: !empty(ipRulesAllowedIpRanges) == true && publicNetworkAccess == 'disabled' ? {
      defaultAction: networkRuleSetDefaultAction
      ipRules: ipRulesAllowedIpRanges
    } : null
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

@description('The resource ID of the deployed Search Service.')
output resourceId string = account.id
@description('The name of the deployed Search Service.')
output name string = account.name
