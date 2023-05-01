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

@description('Optional. The sku of the resource.')
@allowed([
  'standard'
  'premium'
])
param sku string = 'premium'

@description('Optional. Whether or not public endpoint access is allowed for this server. Only Disable if you wish to restrict to just private endpoints and VNET.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. Enable or disable public IP for the resource. Vnet injection requires public IP to be disabled.')
param enableNoPublicIp bool = true

@description('Managed resource group resource id.')
param managedResourceGroupId string

@description('Databricks virtual network resource id.')
param customVirtualNetworkId string

@description('Private subnet name for databricks.')
param customPrivateSubnetName string

@description('Public subnet name for databricks.')
param customPublicSubnetName string

@description('Optional. NSG rules to be applied to the custom subnets.  NoAzureDatabricksRules must be selected to use private endpoints.')
@allowed([
  'AllRules'
  'NoAzureDatabricksRules'
  'NoAzureServiceRules'
])
param requiredNsgRules string = 'NoAzureDatabricksRules'

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'allLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'allLogs'
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

var lockName = toLower('${databricks.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${databricks.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

resource databricks 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    managedResourceGroupId: managedResourceGroupId
    requiredNsgRules: requiredNsgRules
    parameters: {
      customPrivateSubnetName: { value: customPrivateSubnetName }
      customPublicSubnetName: { value: customPublicSubnetName }
      customVirtualNetworkId: { value: customVirtualNetworkId }
      enableNoPublicIp: { value: enableNoPublicIp }
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourcelock != 'NotSpecified') {
  scope: databricks
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: databricks
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
  }
}

@description('The name of the deployed databricks service.')
output name string = databricks.name

@description('The resource ID of the deployed databricks service.')
output resourceId string = databricks.id
