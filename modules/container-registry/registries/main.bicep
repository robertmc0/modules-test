metadata name = 'Container Registry'
metadata description = 'This module deploys Microsoft.ContainerRegistry registry at the subscription level'
metadata owner = 'Arinco'

@description('Provide a globally unique name of your Azure Container Registry.')
@maxLength(50)
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

@description('Optional. The SKU name of the container registry.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?pivots=deployment-language-bicep#sku'
  example: {
    tagKey: 'string'
  }
})
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Optional. The value that indicates whether the admin user is enabled.')
param adminUserEnabled bool = false

@description('Optional. Enable a single data endpoint per region for serving data. Requires Premium sku.')
param dataEndpointEnabled bool = false

@description('Optional. Enable encryption settings of container registry. Requires Premium sku.')
param encryptionEnabled bool = false

@description('Optional. The resource ID of the user assigned managed identity.')
param userAssignedIdentity string = ''

@description('Optional. The Client ID of the identity which will be used to access Key Vault.')
param userAssignedIdentityId string = ''

@description('Optional. The Key Vault URI to access the encryption key. Requires Premium sku.')
param keyVaultIdentifier string = ''

@description('Optional. Enable Zone Redundancy settings of container registry. Must be in a region that supports it. Requires Premium sku.')
param zoneRedundancy bool = false

@description('Optional. Whether to allow trusted Azure services to access a network restricted registry.')
param allowNetworkRuleBypass bool = true

@description('Optional. Whether or not public network access is allowed for the container registry. Requires Premium sku.')
param disablePublicNetworkAccess bool = false

@description('Optional. Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed. Requires Premium sku.')
param allowedIpRanges array = []

@description('Optional. The default action of allow or deny when no other rules match. Requires Premium sku.')
@allowed([
  'Allow'
  'Deny'
])
param networkRuleSetDefaultAction string = 'Deny'

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'audit'
  'allLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'audit'
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

var lockName = toLower('${registry.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${registry.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

var ipRulesAllowedIpRanges = [for ip in allowedIpRanges: {
  value: ip
  action: 'Allow'
}]

resource registry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  identity: !empty(userAssignedIdentity) == true ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity}': {}
    }
  } : null
  properties: {
    adminUserEnabled: adminUserEnabled
    dataEndpointEnabled: dataEndpointEnabled ? dataEndpointEnabled : null
    encryption: encryptionEnabled ? {
      keyVaultProperties: {
        identity: userAssignedIdentityId
        keyIdentifier: keyVaultIdentifier
      }
      status: 'enabled'
    } : null
    zoneRedundancy: zoneRedundancy ? 'Enabled' : 'Disabled'
    publicNetworkAccess: disablePublicNetworkAccess ? 'Disabled' : 'Enabled'
    networkRuleBypassOptions: allowNetworkRuleBypass ? 'AzureServices' : 'None'
    networkRuleSet: !empty(ipRulesAllowedIpRanges) == true && disablePublicNetworkAccess == false ? {
      defaultAction: networkRuleSetDefaultAction
      ipRules: ipRulesAllowedIpRanges
    } : null
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: registry
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: registry
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

@description('The name of the deployed key vault.')
output name string = registry.name

@description('The resource ID of the deployed key vault.')
output resourceId string = registry.id

@description('The login server URI of the deployed container registry.')
output loginServer string = registry.properties.loginServer
