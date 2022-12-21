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

@description('Optional. The sku of the Storage Account.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param sku string = 'Standard_GRS'

@description('Optional. The kind of Storage Account.')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@description('Optional. Storage Account access tier, Hot for frequently accessed data or Cool for infrequently accessed data.')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Allow or disallow public network access to Storage Account.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. Amount of days the soft deleted data is stored and available for recovery.')
@minValue(1)
@maxValue(365)
param deleteRetentionPolicy int = 7

@description('Optional. If true, enables Hierarchical Namespace for the Storage Account.')
param enableHierarchicalNamespace bool = false

@description('Optional. A boolean indicating whether or not the service applies a secondary layer of encryption with platform managed keys for data at rest. For security reasons, it is recommended to set it to true.')
param requireInfrastructureEncryption bool = true

@description('Optional. Containers to create in the Storage Account.')
@metadata({
  name: 'Container name.'
  publicAccess: 'Specifies whether data in the container may be accessed publicly and the level of access. Accepted values: None, Blob, Container.'
})
param containers array = []

@description('Optional. Files shares to create in the Storage Account.')
@metadata({
  name: 'File share name.'
  tier: 'File share tier. Accepted values are Hot, Cool, TransactionOptimized or Premium.'
  protocol: 'The authentication protocol that is used for the file share. Accepted values are SMB and NFS.'
  quota: 'The maximum size of the share, in gigabytes.'
})
param fileShares array = []

@description('Optional. Queue to create in the Storage Account.')
@metadata({
  name: 'Queue name.'
})
param queues array = []

@description('Optional. Tables to create in the Storage Account.')
@metadata({
  name: 'Table name.'
})
param tables array = []

@description('Optional. Rule definitions governing the Storage network access.')
@metadata({
  bypass: 'Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging, Metrics, AzureServices.'
  defaultAction: 'Specifies the default action of allow or deny when no other rules match. Accepted values: "Allow" or "Deny".'
  ipRules: [
    {
      action: 'Allow'
      value: 'IPv4 address or CIDR range.'
    }
  ]
  virtualNetworkRules: [
    {
      action: 'The action of virtual network rule.'
      id: 'Full resource id of a vnet subnet.'
    }
  ]
  resourceAccessRules: [
    {
      resourceId: '	Resource Id.'
      tenantId: 'Tenant Id.'
    }
  ]
})
param networkAcls object = {}

@description('Optional. Allow large file shares if set to Enabled. It cannot be disabled once it is enabled.')
param largeFileSharesState string = 'Disabled'

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourcelock string = 'NotSpecified'

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log categories that will be streamed.')
@allowed([
  'StorageRead'
  'StorageWrite'
  'StorageDelete'
])
param diagnosticLogCategoriesToEnable array = [
  'StorageRead'
  'StorageWrite'
  'StorageDelete'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'Transaction'
])
param diagnosticMetricsToEnable array = [
  'Transaction'
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

var supportsBlobService = kind == 'BlockBlobStorage' || kind == 'BlobStorage' || kind == 'StorageV2' || kind == 'Storage'

var supportsFileService = kind == 'FileStorage' || kind == 'StorageV2' || kind == 'Storage'

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var lockName = toLower('${storage.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${storage.name}-dgs')

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
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

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: kind
  identity: identity
  properties: {
    accessTier: accessTier
    isHnsEnabled: enableHierarchicalNamespace ? enableHierarchicalNamespace : null
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: supportsBlobService ? {
          enabled: true
        } : null
        file: supportsFileService ? {
          enabled: true
        } : null
      }
      requireInfrastructureEncryption: kind != 'Storage' ? requireInfrastructureEncryption : null
    }
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    largeFileSharesState: largeFileSharesState
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = if (supportsBlobService) {
  parent: storage
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: deleteRetentionPolicy
    }
  }
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = [for container in containers: {
  parent: blobServices
  name: container.name
  properties: {
    publicAccess: container.publicAccess
  }
}]

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = if (supportsFileService) {
  parent: storage
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      days: deleteRetentionPolicy
      enabled: true
    }
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-08-01' = [for fileShare in fileShares: {
  parent: fileServices
  name: fileShare.name
  properties: {
    accessTier: contains(fileShare, 'tier') ? fileShare.tier : null
    enabledProtocols: contains(fileShare, 'protocol') ? fileShare.protocol : 'SMB'
    shareQuota: contains(fileShare, 'quota') ? fileShare.quota : 5120
  }
}]

resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = if (!empty(queues)) {
  parent: storage
  name: 'default'
  properties: {}
}

resource storageQueues 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = [for queue in queues: {
  parent: queueServices
  name: queue.name
  properties: {}
}]

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' = if (!empty(tables)) {
  parent: storage
  name: 'default'
  properties: {}
}

resource storageTables 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-09-01' = [for table in tables: {
  parent: tableServices
  name: table.name
  properties: {}
}]

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: storage
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnosticsStorage 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: storage
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    metrics: diagnosticsMetrics
  }
}

resource diagnosticsBlobServices 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: blobServices
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

resource diagnosticsFileServices 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && !empty(fileShares)) {
  scope: fileServices
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

resource diagnosticsQueueServices 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && !empty(queues)) {
  scope: queueServices
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

@description('The name of the deployed storage account.')
output name string = storage.name

@description('The resource ID of the deployed storage account.')
output resourceId string = storage.id
