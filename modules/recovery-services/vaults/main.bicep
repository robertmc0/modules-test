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

@description('Optional. The sku of the recovery services vault.')
@allowed([
  'Standard'
  'RS0'
])
param sku string = 'RS0'

@description('Optional. Storage replication type of the recovery services vault.')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
  'ReadAccessGeoZoneRedundant'
  'ZoneRedundant'
])
param storageType string = 'GeoRedundant'

@description('Optional. Enable cross region restore.')
param enablecrossRegionRestore bool = false

@description('Optional. Backup policies.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults/backuppolicies?pivots=deployment-language-bicep#protectionpolicy-objects'
  example: {
    name: 'string'
    properties: {
      backupManagementType: 'string'
      instantRpRetentionRangeInDays: 'int'
      schedulePolicy: {
        scheduleRunFrequency: 'string'
        scheduleRunTimes: [
          'string'
        ]
        schedulePolicyType: 'string'
      }
      timeZone: 'string'
      retentionPolicy: {
        dailySchedule: {
          retentionTimes: [
            'string'
          ]
          retentionDuration: {
            count: 'int'
            durationType: 'string'
          }
        }
        retentionPolicyType: 'string'
      }
    }
  }
})
param backupPolicies array = []

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourceLock string = 'NotSpecified'

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'AllLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'Health'
])
param diagnosticMetricsToEnable array = [
  'Health'
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

@description('Optional. Add existing Azure virtual machine(s) to backup policy.')
@metadata({
  resourceId: 'Azure virtual machine resource id.'
  backupPolicyName: 'Backup policy name.'
})
param addVmToBackupPolicy array = []

var vmBackupConfig = [for vm in addVmToBackupPolicy: {
  backupPolicyName: vm.backupPolicyName
  resourceId: vm.resourceId
  backupFabric: 'Azure'
  protectionContainer: 'iaasvmcontainer;iaasvmcontainerv2;${split(vm.resourceId, '/')[4]};${last(split(vm.resourceId, '/'))}'
  protectedItem: 'vm;iaasvmcontainerv2;${split(vm.resourceId, '/')[4]};${last(split(vm.resourceId, '/'))}'
}]

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var lockName = toLower('${vault.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${vault.name}-dgs')

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

resource vault 'Microsoft.RecoveryServices/vaults@2022-04-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {}
  sku: {
    name: sku
    tier: 'Standard'
  }

}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-03-01' = [for policy in backupPolicies: {
  parent: vault
  name: policy.name
  location: location
  properties: policy.properties
}]

resource vaultConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2022-03-01' = {
  name: '${vault.name}/vaultStorageConfig'
  properties: {
    crossRegionRestoreFlag: enablecrossRegionRestore
    storageType: storageType
  }
}

resource vaultProtectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-03-01' = [for vm in vmBackupConfig: {
  name: '${vault.name}/${vm.backupFabric}/${vm.protectionContainer}/${vm.protectedItem}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: '${vault.id}/backupPolicies/${vm.backupPolicyName}'
    sourceResourceId: vm.resourceId
  }
}]

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: vault
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: vault
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

@description('The name of the deployed recovery services vault.')
output name string = vault.name

@description('The resource ID of the deployed recovery services vault.')
output resourceId string = vault.id
