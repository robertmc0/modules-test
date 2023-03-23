@description('Name of Elastic Pool to create.')
param name string

@description('Location of resource.')
param location string

@description('Name of existing Azure SQL Server.')
param sqlServerName string

@description('A predefined set of SkuTypes. Currently template not configured to support Hyper-Scale or Business Critical.')
@allowed([
  'BasicPool,'
  'StandardPool'
  'PremiumPool'
  'GP_Fsv2'
  'GP_Gen5'
])
param skuType string

@description('Capacity of Elastic Pool.  If DTU model, define amount of DTU. If vCore model, define number of vCores.')
param skuCapacity int

@description('Optional. Minimum capacity per database.  If DTU model, define amount of DTU. If vCore model, define number of vCores. Requires string to handle decimals.')
param databaseMinCapacity string = '0'

@description('Optional. Maximum capacity per database.  If DTU model, define amount of DTU. If vCore model, define number of vCores.')
param databaseMaxCapacity int = skuCapacity

@description('Maximum size in bytes for the Elastic Pool.')
param maxPoolSize int

@description('Optional. Whether the databases in pool zone redundant. Only supported in some regions.')
param zoneRedundant bool = false

@description('Optional. For Azure Hybrid Benefit, use BasePrice.')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string = 'LicenseIncluded'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param resourcelock string = 'NotSpecified'

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'Basic'
  'InstanceAndAppAdvanced'
])
param diagnosticMetricsToEnable array = [
  'Basic'
  'InstanceAndAppAdvanced'
]

var lockName = toLower('${elasticPool.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${elasticPool.name}-dgs')

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

// Object map to help set SKU properties for elastic pool
var skuMap = {
  BasicPool: {
    name: 'BasicPool'
    tier: 'Basic'
    family: json('null')
  }
  StandardPool: {
    name: 'StandardPool'
    tier: 'Standard'
    family: json('null')
  }
  PremiumPool: {
    name: 'PremiumPool'
    tier: 'Premium'
    family: json('null')
  }
  GP_Gen5: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
  }
  GP_Fsv2: {
    name: 'GP_S_Fsv2'
    tier: 'GeneralPurpose'
    family: 'Fsv2'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' existing = {
  name: sqlServerName
}

resource elasticPool 'Microsoft.Sql/servers/elasticPools@2022-05-01-preview' = {
  parent: sqlServer
  name: name
  location: location
  tags: tags
  sku: {
    name: skuMap[skuType].name
    tier: skuMap[skuType].tier
    family: skuMap[skuType].family
    capacity: skuCapacity
  }
  properties: {
    licenseType: licenseType
    maxSizeBytes: maxPoolSize
    perDatabaseSettings: {
      minCapacity: any(databaseMinCapacity)
      maxCapacity: databaseMaxCapacity
    }
    zoneRedundant: zoneRedundant
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: elasticPool
  name: diagnosticsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticLogAnalyticsWorkspaceId) ? diagnosticLogAnalyticsWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: elasticPool
  name: lockName
  properties: {
    level: resourcelock
    notes: resourcelock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the elastic pool.')
output name string = elasticPool.name
@description('The resource ID of the elastic pool.')
output resourceId string = elasticPool.id
