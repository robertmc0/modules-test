metadata name = 'Sql Server Database'
metadata description = 'This module deploys Microsoft.Sql.Server databases'
metadata owner = 'Arinco'

@description('Name of existing Azure SQL Server.')
param sqlServerName string

@description('Name of Database to create.')
param databaseName string

@description('Location of resource.')
param location string

@description('Optional. Specifies the mode of database creation.')
@allowed([
  'Copy'
  'Default'
  'OnlineSecondary'
  'PointInTimeRestore'
  'Recovery'
  'Restore'
  'RestoreExternalBackup'
  'RestoreExternalBackupSecondary'
  'RestoreLongTermRetentionBackup'
  'Secondary'
])
param createMode string = 'Default'

@description('A predefined set of SkuTypes. Currently template not configured to support Hyper-Scale or Business Critical.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
  'vCoreGen5'
  'vCoreGen5Serverless'
  'ElasticPool'
])
param skuType string

@description('Optional. If DTU model, define amount of DTU. If vCore model, define number of vCores (max for serverless). Not used for Elastic pool.')
param skuCapacity int = 0 //overridden by skuMap/defaultCapacity if not set

@description('Optional. Min vCore allocation. Applicable for vCore Serverless model only. Requires string to handle decimals.')
param skuMinCapacity string = '0.5'

@description('Maximum database size in bytes for allocation.')
param maxDbSize int

@description('Optional. Minutes before Auto Pause. Applicable for vCore Serverless model only.')
param autoPauseDelay int = 60

@description('Optional. Defines the short term retention period.  Maximum of 35 days.')
param retentionPeriod int = 35

@description('Optional. The SQL database Collation.')
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Optional. Whether the databases are zone redundant. Only supported in some regions.')
param zoneRedundant bool = false

@description('Optional. For Azure Hybrid Benefit, use BasePrice.')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string = 'LicenseIncluded'

@description('Optional. Allow ReadOnly from secondary endpoints.')
param readScaleOut string = 'Disabled'

@description('Optional. Set location of backups, geo, local or zone.')
param requestedBackupStorageRedundancy string = 'Geo'

@description('Optional. Elastic Pool ID.')
param elasticPoolId string = ''

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

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

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

var lockName = toLower('${sqlDatabase.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${sqlDatabase.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

// Object map to help set SKU properties for database
var skuMap = {
  vCoreGen5: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    defaultCapacity: 2 // vCores
  }
  vCoreGen5Serverless: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    defaultCapacity: 2 // vCores
  }
  Basic: {
    name: 'Basic'
    tier: 'Basic'
    defaultCapacity: 10 // DTUs
  }
  Standard: {
    name: 'Standard'
    tier: 'Standard'
    defaultCapacity: 10 // DTUs
  }
  Premium: {
    name: 'Premium'
    tier: 'Premium'
    defaultCapacity: 10 // DTUs
  }
  ElasticPool: {
    name: 'ElasticPool'
    defaultCapacity: 0 // Not used
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-08-01-preview' existing = {
  name: sqlServerName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: skuMap[skuType].name
    tier: contains(skuMap[skuType], 'tier') ? skuMap[skuType].tier : null
    family: contains(skuMap[skuType], 'family') ? skuMap[skuType].family : null
    capacity: skuCapacity != 0 ? skuCapacity : skuMap[skuType].defaultCapacity
  }
  properties: {
    collation: databaseCollation
    maxSizeBytes: maxDbSize
    zoneRedundant: zoneRedundant
    licenseType: licenseType
    readScale: readScaleOut
    minCapacity: skuType == 'vCoreGen5Serverless' ? any(skuMinCapacity) : null
    autoPauseDelay: skuType == 'vCoreGen5Serverless' ? autoPauseDelay : null
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
    createMode: createMode
    elasticPoolId: !empty(elasticPoolId) ? elasticPoolId : null
  }
}

resource retention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2022-08-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    retentionDays: retentionPeriod
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: sqlDatabase
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

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: sqlDatabase
  name: lockName
  properties: {
    level: resourcelock
    notes: resourcelock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the sql database.')
output name string = sqlDatabase.name
@description('The resource ID of the sql database.')
output resourceId string = sqlDatabase.id
