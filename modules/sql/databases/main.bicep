@description('Name of existing Azure SQL Server.')
param sqlServerName string

@description('Name of Database to create.')
param databaseName string

@description('Location of resource.')
param location string

@description('Specifies the mode of database creation.')
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
])
param skuType string

@description('If DTU model, define amount of DTU. If vCore model, define number of vCores (max for serverless).')
param skuCapacity int

@description('Min vCore allocation. Applicable for vCore Serverless model only. Requires string to handle decimals.')
param skuMinCapacity string = '0.5'

@description('Maximum database size in bytes for allocation.')
param maxDbSize int

@description('Minutes before Auto Pause. Applicable for vCore Serverless model only.')
param autoPauseDelay int = 60

@description('Defines the short term retention period.  Maximum of 35 days.')
param retentionPeriod int = 35

@description('The SQL database Collation.')
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Whether the databases are zone redundant. Only supported in some regions.')
param zoneRedundant bool = false

@description('For Azure Hybrid Benefit, use BasePrice.')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string = 'LicenseIncluded'

@description('Allow ReadOnly from secondary endpoints.')
param readScaleOut string = 'Disabled'

@description('Set location of backups, geo, local or zone.')
param requestedBackupStorageRedundancy string = 'Geo'

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

// Object map to help set SKU properties for database
var skuMap = {
  vCoreGen5: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    kind: 'v12.0,user,vcore'
  }
  vCoreGen5Serverless: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    kind: 'v12.0,user,vcore,serverless'
  }
  Basic: {
    name: 'Basic'
    tier: 'Basic'
    family: json('null')
    kind: 'v12.0,user'
  }
  Standard: {
    name: 'Standard'
    tier: 'Standard'
    family: json('null')
    kind: 'v12.0,user'
  }
  Premium: {
    name: 'Premium'
    tier: 'Premium'
    family: json('null')
    kind: 'v12.0,user'
  }
}

// Existing Azure SQL Server
resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' existing = {
  name: sqlServerName
}

// Resource Definition
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: skuMap[skuType].name
    tier: skuMap[skuType].tier
    family: skuMap[skuType].family
    capacity: skuCapacity
  }
  properties: {
    collation: databaseCollation
    maxSizeBytes: maxDbSize
    zoneRedundant: zoneRedundant
    licenseType: licenseType
    readScale: readScaleOut
    minCapacity: skuType == 'vCoreGen5Serverless' ? any(skuMinCapacity) : json('null')
    autoPauseDelay: skuType == 'vCoreGen5Serverless' ? autoPauseDelay : json('null')
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
    createMode: createMode
  }
}

// Short Term Retention Policy
resource retention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-02-01-preview' = {
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
