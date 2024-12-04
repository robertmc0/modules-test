metadata name = 'Public IP Module'
metadata description = 'This module deploys a Microsoft.Network/publicIPAddresses resource.'
metadata owner = 'Arinco'

@description('Name of the Public IP resource.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. A name associated with Azure region. e.g example.australiasoutheast.cloudapp.azure.com.')
param dnsNameLabel string = ''

@description('Optional. The Public IP allocation method.')
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string = 'Static'

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

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

var publicIpDiagnosticsName = toLower('${publicIpAddress.name}-dgs')

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

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: empty(dnsNameLabel) ? {} : { domainNameLabel: dnsNameLabel }
  }
}

resource diagnosticsPublicIp 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: publicIpAddress
  name: publicIpDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId)
      ? null
      : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

@description('The ID of the Public IP resource.')
output resourceId string = publicIpAddress.id

@description('The name of the Public IP resource.')
output name string = publicIpAddress.name

@description('The IP Address of the Public IP resource.')
output ipAddress string = publicIpAddress.properties.ipAddress

@description('The DNS Label of the Public IP resource.')
output dnsName string = publicIpAddress.properties.dnsSettings.domainNameLabel
