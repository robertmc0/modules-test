metadata name = 'MySQL Flexible Servers'
metadata description = 'Deploy Azure Database for MySQL Flexible Servers'
metadata owner = 'Arinco'

import * as Types from './types.bicep'

@description('Required. The name of the MySQL flexible server.')
@minLength(5)
@maxLength(50)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. The administrator login name of a server. Can only be specified when the MySQL server is being created.')
param administratorLogin string?

@description('Optional. The administrator login password.')
@secure()
param administratorLoginPassword string?

@description('Optional. The Azure AD administrators when AAD authentication enabled.')
@metadata({
  exmaple: {
    identityResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity'
    login: 'string'
    sid: 'identity_object_id'
  }
})
param administrator Types.administratorType?

@description('Optional. The list of databases to be deploy to the MySQL flexible server.')
@metadata({
  example: [
    {
      name: 'string'
      charset: 'string'
      collation: 'string'
    }
  ]
})
param databases array = []

@description('Required. The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3.')
param skuName string

@allowed([
  'GeneralPurpose'
  'Burstable'
  'MemoryOptimized'
])
@description('Required. The tier of the particular SKU. Tier must align with the "skuName" property. Example, tier cannot be "Burstable" if skuName is "Standard_D4s_v3".')
param tier string

@allowed([
  ''
  '1'
  '2'
  '3'
])
@description('Optional. Availability zone information of the server. Default will have no preference set.')
param availabilityZone string = ''

@description('Optional. Standby availability zone information of the server. Default will have no preference set.')
param highAvailabilityZone string = ''

@minValue(1)
@maxValue(35)
@description('Optional. Backup retention days for the server.')
param backupRetentionDays int = 7

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. A value indicating whether Geo-Redundant backup is enabled on the server.')
param geoRedundantBackup string = 'Enabled'

@allowed([
  'Default'
  'GeoRestore'
  'PointInTimeRestore'
  'Replica'
])
@description('Optional. The mode to create a new MySQL server.')
param createMode string = 'Default'

@allowed([
  'Disabled'
  'SameZone'
  'ZoneRedundant'
])
@description('Optional. The mode for High Availability (HA). It is not supported for the Burstable pricing tier and Zone redundant HA can only be set during server provisioning.')
param highAvailability string = 'Disabled'

@description('Optional. Properties for the maintenence window. If provided, "customWindow" property must exist and set to "Enabled". Use the maintenanceWindow property only when updating an existing flexible server. When creating a new flexible servcer, don\'t specify values for this property.')
@metadata({

  example: {
    customWindow: 'string'
    dayOfWeek: 1
    startHour: 1
    startMinute: 1
  }
})
param maintenanceWindow object = {}

@description('Optional. Delegated subnet arm resource ID. Used when the desired connectivity mode is "Private Access" - virtual network integration. Delegation must be enabled on the subnet for MySQL Flexible Servers and subnet CIDR size is /29.')
param delegatedSubnetResourceId string?

@description('Conditional. Private dns zone arm resource ID. Used when the desired connectivity mode is "Private Access". Required if "delegatedSubnetResourceId" is used and the Private DNS Zone name must end with mysql.database.azure.com in order to be linked to the MySQL Flexible Server.')
param privateDnsZoneResourceId string?

@description('Optional. Specifies whether public network access is allowed for this server. Set to "Enabled" to allow public access, or "Disabled" (default) when the server has VNet integration.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Conditional. Restore point creation time (ISO8601 format), specifying the time to restore from. Required if "createMode" is set to "PointInTimeRestore".')
param restorePointInTime string = ''

@allowed([
  'None'
  'Replica'
  'Source'
])
@description('Optional. The replication role.')
param replicationRole string = 'None'

@description('Conditional. The source MySQL server ID. Required if "createMode" is set to "PointInTimeRestore".')
param sourceServerResourceId string?

@allowed([
  'Disabled'
  'Enabled'
])
@description('Conditional. Enable Storage Auto Grow or not. Storage auto-growth prevents a server from running out of storage and becoming read-only. Required if "highAvailability" is not "Disabled".')
param storageAutoGrow string = 'Disabled'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Enable IO Auto Scaling or not. The server scales IOPs up or down automatically depending on your workload needs.')
param storageAutoIoScaling string = 'Disabled'

@minValue(360)
@maxValue(48000)
@description('Optional. Storage IOPS for a server. Max IOPS are determined by compute size.')
param storageIOPS int = 1000

@allowed([
  20
  32
  64
  128
  256
  512
  1024
  2048
  4096
  8192
  16384
])
@description('Optional. Max storage allowed for a server. In all compute tiers, the minimum storage supported is 20 GiB and maximum is 16 TiB.')
param storageSizeGB int = 64

@allowed([
  '5.7'
  '8.0.21'
])
@description('Optional. MySQL Server version.')
param version string = '8.0.21'

@description('Optional. The firewall rules to create in the MySQL flexible server.')
@metadata({
  example: [
    {
      name: 'AllowAllWindowsAzureIps'
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  ]
})
param firewallRules array = []

@description('Optional. Enable/Disable Advanced Threat Protection (Microsoft Defender) for the server.')
@allowed([
  'Enabled'
  'Disabled'
])
param advancedThreatProtection string = 'Enabled'

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

@description('Optional. The ID(s) to assign to the resource.')
@metadata({
  example: {
    '/subscriptions/<subscription>/resourceGroups/<rgp>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-umi': {}
  }
})
param userAssignedIdentities object = {}

@description('Optional. The type of identity for the resource.')
@allowed([
    'None'
    'UserAssigned'
])
param identityType string = 'None'

var standByAvailabilityZoneTable = {
  Disabled: null
  SameZone: availabilityZone
  ZoneRedundant: highAvailabilityZone
}

var standByAvailabilityZone = standByAvailabilityZoneTable[?highAvailability]

var diagnosticsName = toLower('${flexibleServer.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var lockName = toLower('${flexibleServer.name}-${resourcelock}-lck')

resource flexibleServer 'Microsoft.DBforMySQL/flexibleServers@2023-12-30' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: tier
  }
  identity: identity
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    availabilityZone: availabilityZone
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    createMode: createMode
    highAvailability: {
      mode: highAvailability
      standbyAvailabilityZone: standByAvailabilityZone
    }
    maintenanceWindow: !empty(maintenanceWindow)
      ? {
          customWindow: maintenanceWindow.customWindow
          dayOfWeek: maintenanceWindow.customWindow == 'Enabled' ? maintenanceWindow.dayOfWeek : 0
          startHour: maintenanceWindow.customWindow == 'Enabled' ? maintenanceWindow.startHour : 0
          startMinute: maintenanceWindow.customWindow == 'Enabled' ? maintenanceWindow.startMinute : 0
        }
      : null
    network: {
      delegatedSubnetResourceId: delegatedSubnetResourceId
      privateDnsZoneResourceId: privateDnsZoneResourceId
      publicNetworkAccess: publicNetworkAccess
    }
    replicationRole: replicationRole
    restorePointInTime: restorePointInTime
    sourceServerResourceId: sourceServerResourceId
    storage: {
      autoGrow: storageAutoGrow
      autoIoScaling: storageAutoIoScaling
      iops: storageIOPS
      storageSizeGB: storageSizeGB
    }
    version: version
  }
}

resource flexibleServer_databases 'Microsoft.DBforMySQL/flexibleServers/databases@2023-12-30' = [
  for (database, index) in databases: {
    name: database.name
    parent: flexibleServer
    properties: {
      charset: database.charset
      collation: database.collation
    }
  }
]

resource firewallRule 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-06-30' = [
  for (firewallRule, index) in firewallRules: {
    name: firewallRule.name
    parent: flexibleServer
    properties: {
      endIpAddress: firewallRule.startIpAddress
      startIpAddress: firewallRule.endIpAddress
    }
  }
]

resource flexibleServer_administrator 'Microsoft.DBforMySQL/flexibleServers/administrators@2023-06-30' = if (!empty(administrator)) {
  name: 'ActiveDirectory'
  parent: flexibleServer
  properties: {
    administratorType: 'ActiveDirectory'
    identityResourceId: administrator.?identityResourceId
    login: administrator.?login
    sid: administrator.?sid
    tenantId: administrator.?tenantId ?? tenant().tenantId
  }
}

resource advancedThreatProtectionSettings 'Microsoft.DBforMySQL/flexibleServers/advancedThreatProtectionSettings@2023-12-30' = {
  parent: flexibleServer
  name: 'Default'
  properties: {
    state: advancedThreatProtection
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: flexibleServer
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: flexibleServer
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

@description('The name of the deployed MySQL Flexible server.')
output name string = flexibleServer.name

@description('The resource ID of the deployed MySQL Flexible server.')
output resourceId string = flexibleServer.id

@description('The FQDN of the MySQL Flexible server.')
output fqdn string = flexibleServer.properties.fullyQualifiedDomainName
