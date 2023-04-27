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

@description('Optional. The sku of this ExpressRoute circuit.')
@allowed([
  'Basic'
  'Local'
  'Premium'
  'Standard'
])
param tier string = 'Standard'

@description('The billing model of the ExpressRoute circuit.')
@allowed([
  'MeteredData'
  'UnlimitedData'
])
param billingModel string

@description('Optional. Allow classic operations.')
param allowClassicOperations bool = false

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('The bandwidth of the ExpressRoute circuit.')
param bandwidthInMbps int

@description('The peering location.')
param peeringLocation string

@description('The service provider name.')
param serviceProviderName string

@description('Optional. Peering configuration.')
@metadata({
  name: 'The name of the peering'
  peeringType: 'The type of peering.'
  peerASN: 'The peer ASN.'
  primaryPeerAddressPrefix: 'The primary address prefix.'
  secondaryPeerAddressPrefix: 'The secondary address prefix.'
  vlanId: 'The VLAN ID.'
})
param peeringConfig object = {}

var peeringConfiguration = [
  {
    name: peeringConfig.name
    properties: {
      peeringType: peeringConfig.peeringType
      peerASN: peeringConfig.peerASN
      primaryPeerAddressPrefix: peeringConfig.primaryPeerAddressPrefix
      secondaryPeerAddressPrefix: peeringConfig.secondaryPeerAddressPrefix
      vlanId: peeringConfig.vlanId
    }
  }
]

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

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

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

var lockName = toLower('${expressRoute.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${expressRoute.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

resource expressRoute 'Microsoft.Network/expressRouteCircuits@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: '${tier}_${billingModel}'
    family: billingModel
    tier: tier
  }
  properties: {
    allowClassicOperations: allowClassicOperations
    serviceProviderProperties: {
      bandwidthInMbps: bandwidthInMbps
      peeringLocation: peeringLocation
      serviceProviderName: serviceProviderName
    }
    peerings: !empty(peeringConfig) ? peeringConfiguration : null
  }

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: expressRoute
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: expressRoute
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

@description('The name of the deployed express route circuit.')
output name string = expressRoute.name

@description('The resource ID of the deployed express route circuit.')
output resourceId string = expressRoute.id
