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

@minLength(1)
@description('The name of the Cosmos DB account.')
param name string

@minLength(1)
@description('The database to create in the Cosmos DB account.')
param databaseName string

@description('An array that contains the georeplication locations enabled for the Cosmos DB account.')
@metadata({
  locations: [
    {
      locationName: 'australiaeast'
      failoverPriority: 0
      isZoneRedundant: true
    }
    {
      locationName: 'australiasoutheast'
      failoverPriority: 1
      isZoneRedundant: false
    }
  ] })
param locations array

@description('Container configurations to apply to the Cosmos DB account.')
param containerConfigurations array

@description('Access permissions to apply to the Cosmos DB account.')
@metadata({
  accountAccess: {
    reader: {
      principals: [
        'principalId1'
      ]
    }
    contributor: {
      principals: [
        'principalId1'
        'principalId2'
      ]
    }
  }
})
param accountAccess object

@description('Optional. The full resource ID of a subnet in a virtual network to deploy the Cosmos DB account in.')
param virtualNetworkSubnetId string = ''

@description('Optional. Indicates whether to allow public network access. Defaults to Disabled.')
param publicNetworkAccess string = 'Disabled'

@description('Optional. Indicates whether to disable local authentication with access keys. Defaults to true.')
param disableLocalAuth bool = true

@description('Optional. Disable write operations on metadata resources (databases, containers, throughput) via account keys. Defaults to true.')
param disableKeyBasedMetadataWriteAccess bool = true

@description('Optional. The consistency policy for the Cosmos DB account. Defaults to Session consistency.')
param consistencyPolicy object = {
  defaultConsistencyLevel: 'Session'
}

@description('Optional. Indicates whether multiple write locations is enabled.')
param enableMultipleWriteLocations bool = false

@description('Optional. Indicates whether automatic failover is enabled.')
param enableAutomaticFailover bool = false

@description('Optional. Indicates whether to enable storage analytics.')
param enableAnalyticalStorage bool = false

@description('Optional. Analytical storage specific properties.')
param analyticalStorageConfiguration object = {}

@description('Optional. Total capacity limit for the Cosmos DB account.')
@metadata({
  capacity: {
    totalThroughputLimit: 10000
  }
})
param capacity object = {}

@description('Optional. The default scale settings to apply to each container, when not using dedicated (database level) scale settings. Defaults to autoscale with max throughput of 1000 RUs.')
param defaultContainerScaleSettings object = {
  autoscaleSettings: {
    maxThroughput: 1000
  }
}

@description('Optional. The dedicated (database level) scale settings to apply. When not provided, scale settings are configured on each container.')
@metadata({
  example1: {
    autoscaleSettings: {
      maxThroughput: 10000
    }
  }
  example2: {
    throughput: 1000
  }
})
param databaseScalingOptions object = {}

@description('Optional. List of IP rules to apply to the Cosmos DB account.')
@metadata({
  example: [
    '1.2.3.4'
    '10.0.10.0/28'
  ]
})
param allowedIpAddressOrRanges array = []

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param resourcelock string = 'NotSpecified'

@description('Optional. The name of log category that will be streamed.')
param diagnosticLogCategoryToEnable array = [
  'ControlPlaneRequests'
  'PartitionKeyStatistics'
  'PartitionKeyRUConsumption'
]

@description('Optional. The name of metrics that will be streamed.')
param diagnosticMetricsToEnable array = [
  'Requests'
]

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

var lockName = toLower('${cosmosAccount.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${cosmosAccount.name}-dgs')

var diagnosticsLogs = [for category in diagnosticLogCategoryToEnable: {
  category: category
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

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2022-11-15' = {
  name: name
  kind: 'GlobalDocumentDB'
  location: location
  tags: tags
  properties: {
    databaseAccountOfferType: 'Standard'
    publicNetworkAccess: publicNetworkAccess
    disableKeyBasedMetadataWriteAccess: disableKeyBasedMetadataWriteAccess
    enableMultipleWriteLocations: enableMultipleWriteLocations
    enableAutomaticFailover: enableAutomaticFailover
    enableAnalyticalStorage: enableAnalyticalStorage
    analyticalStorageConfiguration: analyticalStorageConfiguration
    minimalTlsVersion: 'Tls12'
    capacity: capacity
    virtualNetworkRules: !empty(virtualNetworkSubnetId) ? [
      {
        id: virtualNetworkSubnetId
      }
    ] : []
    isVirtualNetworkFilterEnabled: !empty(virtualNetworkSubnetId)
    consistencyPolicy: consistencyPolicy
    disableLocalAuth: disableLocalAuth
    locations: locations
    ipRules: [for ipRule in allowedIpAddressOrRanges: {
      ipAddressOrRange: ipRule
    }]
  }
}

// Cosmos DB SQL Role definitions
var cosmosDBRoleDefintions = {
  Reader: '00000000-0000-0000-0000-000000000001'
  DataContributor: '00000000-0000-0000-0000-000000000002'
}

resource sqlRoleDefinitionReader 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-11-15' existing = {
  parent: cosmosAccount
  name: cosmosDBRoleDefintions.Reader
}

resource sqlRoleDefinitionContributor 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-11-15' existing = {
  parent: cosmosAccount
  name: cosmosDBRoleDefintions.DataContributor
}

var readerPrincipals = contains(accountAccess, 'reader') ? accountAccess.reader.principalIds : []
var contributorPrincipals = contains(accountAccess, 'contributor') ? accountAccess.contributor.principalIds : []

resource sqlRoleAssignmentReader 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-11-15' = [for principalId in readerPrincipals: {
  parent: cosmosAccount
  name: guid(sqlRoleDefinitionReader.id, principalId, cosmosAccount.name)
  properties: {
    roleDefinitionId: sqlRoleDefinitionReader.id
    principalId: principalId
    scope: cosmosAccount.id
  }
}]

resource sqlRoleAssignmentContributor 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-11-15' = [for principalId in contributorPrincipals: {
  parent: cosmosAccount
  name: guid(sqlRoleDefinitionContributor.id, principalId, cosmosAccount.name)
  properties: {
    roleDefinitionId: sqlRoleDefinitionContributor.id
    principalId: principalId
    scope: cosmosAccount.id
  }
}]

resource sqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-11-15' = {
  parent: cosmosAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: empty(databaseScalingOptions) ? null : databaseScalingOptions
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-11-15' = [for containerConfiguration in containerConfigurations: {
  parent: sqlDatabase
  name: containerConfiguration.id
  properties: {
    options: !contains(containerConfiguration, 'options') ? (empty(databaseScalingOptions) ? defaultContainerScaleSettings : null) : containerConfiguration.options
    resource: containerConfiguration
  }
}]

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: cosmosAccount
  name: lockName
  properties: {
    level: resourcelock
    notes: resourcelock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: cosmosAccount
  name: diagnosticsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticLogAnalyticsWorkspaceId) ? diagnosticLogAnalyticsWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
    logAnalyticsDestinationType: 'Dedicated' // Means use Resource Specific named log tables
  }
}

@description('The name of the Cosmos DB account.')
output name string = cosmosAccount.name

@description('The resource ID of the Cosmos DB account.')
output resourceId string = cosmosAccount.id
