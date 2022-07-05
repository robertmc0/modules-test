@description('Name of your Azure PostgreSQL Flexible Server - if error ServerGroupDropping is received during deployment then the server name is not avilable and must be changed to one that is. This can be checked by running a console deployment.')
@minLength(5)
@maxLength(50)
param name string

@description('Location for all resources.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3.')
param skuName string

@description('The tier of the particular SKU, e.g. Burstable.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string

@description('The administrators login name of a server. Can only be specified when the server is being created (and is required for creation).')
param administratorLogin string

@description('The administrator login password (required for server creation).')
@secure()
param administratorLoginPassword string

@description('Backup retention days for the server.')
param backupRetentionDays int

@description('A value indicating whether Geo-Redundant backup is enabled on the server.')
@allowed([
  'Disabled'
  'Enabled'
])
param geoRedundantBackup string = 'Disabled'

@description('The mode to create a new PostgreSQL server.')
@allowed([
  'Create'
  'Default'
  'PointInTimeRestore'
  'Update'
])
param createMode string = 'Create'

@description('The HA mode for the server.')
@allowed([
  'Disabled'
  'ZoneRedundant'
])
param highAvailabilityMode string = 'Disabled'

@description('Availability zone information of the standby.')
param standbyAvailabilityZone string = ''

@description('Private dns zone arm resource id in which to create the Private DNS zone for this PostgreSQL server.')
param privateDnsZoneArmResourceId string = ''

@description('Delegated subnet arm resource id. Subnet must be dedicated to Azure PostgreSQL servers.')
param delegatedSubnetResourceId string = ''

@description('Indicates whether custom maintenance window is enabled or disabled.')
@allowed([
  'disabled'
  'enabled'
])
param customWindow string = 'disabled'

@description('Day of week for maintenance window.')
param dayOfWeek int = 0

@description('Start hour for maintenance window.')
param startHour int = 0

@description('Start minute for maintenance window.')
param startMinute int = 0

@description('Max storage allowed for a server.')
param storageSizeGB int

@description('The version of a server.')
@allowed([
  '11'
  '12'
  '13'
])
param version string

@description('Optional. Enable diagnostic logs')
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
param resourcelock string = 'NotSpecified'

var diagnosticsName = '${name}-dgs'

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

var lockName = toLower('${name}-${resourcelock}-lck')

resource postgresql 'Microsoft.DBforPostgreSQL/flexibleServers@2022-01-20-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    createMode: createMode
    highAvailability: {
      mode: highAvailabilityMode
      standbyAvailabilityZone: standbyAvailabilityZone
    }
    maintenanceWindow: {
      customWindow: customWindow 
      dayOfWeek: dayOfWeek
      startHour: startHour
      startMinute: startMinute
    }
    network: {
      delegatedSubnetResourceId: !empty(delegatedSubnetResourceId) ? delegatedSubnetResourceId : null
      privateDnsZoneArmResourceId: !empty(privateDnsZoneArmResourceId) ? privateDnsZoneArmResourceId : null
    }
    storage: {
      storageSizeGB: storageSizeGB
    }
    version: version
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: postgresql
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

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: postgresql
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}
