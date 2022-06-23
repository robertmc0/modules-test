@description('Storage account name.')
param name string

@description('Storage account location.')
param location string

@description('Storage account sku.')
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

@description('Storage account kind.')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@description('Storage account access tier, Hot for frequently accessed data or Cool for infreqently accessed data.')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Allow or disallow public network access to Storage Account.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Amount of days the soft deleted data is stored and available for recovery.')
@minValue(1)
@maxValue(365)
param deleteRetentionPolicy int = 7

@description('Optional. If true, enables Hierarchical Namespace for the storage account')
param enableHierarchicalNamespace bool = false

@description('Optional. A boolean indicating whether or not the service applies a secondary layer of encryption with platform managed keys for data at rest. For security reasons, it is recommended to set it to true.')
param requireInfrastructureEncryption bool = true

@description('Containers to create in the storage account.')
@metadata({
  name: 'Container name.'
  publicAccess: 'Specifies whether data in the container may be accessed publicly and the level of access. Accepted values: None, Blob, Container.'
})
param containers array = []

@description('Files shares to create in the storage account.')
@metadata({
  name: 'File share name.'
  tier: 'File share tier. Accepted values are Hot, Cool, TransactionOptimized or Premium.'
  protocol: 'The authentication protocol that is used for the file share. Accepted values are SMB and NFS.'
  quota: 'The maximum size of the share, in gigabytes.'
})
param fileShares array = []

@description('Queue to create in the storage account.')
@metadata({
  name: 'Queue name.'
})
param queues array = []

@description('Optional. Tables to create.')
@metadata({
  name: 'Table name.'
})
param tables array = []

@description('Rule definitions governing the Storage network access.')
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

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Specify the type of resource lock.')
param resourcelock string = 'NotSpecified'

@description('Enable diagnostic logs.')
param enableDiagnostics bool = false

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Event hub name. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubName string = ''

var lockName = toLower('${storage.name}-${resourcelock}-lck')
var diagnosticsName = '${storage.name}-dgs'

var supportsBlobService = kind == 'BlockBlobStorage' || kind == 'BlobStorage' || kind == 'StorageV2' || kind == 'Storage'
var supportsFileService = kind == 'FileStorage' || kind == 'StorageV2' || kind == 'Storage'

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')
var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  location: location
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
    accessTier: contains(fileShare,'tier') ? fileShare.tier : null
    enabledProtocols: contains(fileShare,'protocol') ? fileShare.protocol : 'SMB'
    shareQuota: contains(fileShare,'quota') ? fileShare.quota : 5120
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

var diagnosticsMetricsRetentionPolicy = {
  enabled: true
  days: diagnosticLogsRetentionInDays
}

resource diagnosticsStorage 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: storage
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
    ]
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
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
    ]
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
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
    ]
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
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: diagnosticsMetricsRetentionPolicy
      }
    ]
  }
}

@description('The name of the deployed storage account.')
output name string = storage.name

@description('The resource ID of the deployed storage account.')
output resourceId string = storage.id
