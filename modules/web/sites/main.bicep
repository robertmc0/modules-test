metadata name = 'App Service Web Sites'
metadata description = 'This module deploys Microsoft.web/sites AKA App Service Web Sites'
metadata owner = 'Arinco'

@description('Name of App Service Plan')
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

@description('Optional. Specify the type of resource lock.')
@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${name}-${resourceLock}-lck')

@description('Resource ID of the App Service Plan')
param serverFarmId string

@description('The resource ID for the target virtual network subnet.')
param virtualNetworkSubnetId string

@description('Optional. Azure API management settings linked to the app.')
param apiManagementConfig string = ''

@description('Instrumentation key for Application Insights.')
param appInsightsInstrumentationKey string = ''

@description('Connection string for Application Insights.')
param appInsightsConnectionString string = ''

@description('Required. Set to true when using Linux such as for Node runtimes, or false for Windows.')
param isLinux bool

@description('Required when isLinux is true. The version of the runtime stack to use i.e NODE|20-lts.')
param linuxFxVersion string = ''

@description('Required when isLinux is false. The .NET version to use i.e 8.0.')
param dotnetVersion string = ''

@description('Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345).')
param allowedOrigins array

@description('Gets or sets whether CORS requests with credentials are allowed. See https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials for more details.')
param supportCredentials bool

@description('Optional. Application Insights configuration for the app service sites.')
param appSettings array = [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsightsInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appInsightsConnectionString
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~2'
  }
]

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

var diagnosticsName = toLower('${webSites.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

resource webSites 'Microsoft.Web/sites@2020-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    serverFarmId: serverFarmId
    virtualNetworkSubnetId: virtualNetworkSubnetId
    siteConfig: {
      linuxFxVersion: isLinux && !empty(linuxFxVersion) ? linuxFxVersion : null
      windowsFxVersion: !isLinux && !empty(dotnetVersion) ? 'DOTNET|${dotnetVersion}' : null
      appSettings: [for setting in (appSettings ?? []): {
        name: setting.name
        value: setting.value
      }]
      apiManagementConfig: apiManagementConfig != '' ? {
        id: apiManagementConfig
      } : null
      cors: {
        allowedOrigins: allowedOrigins
        supportCredentials: supportCredentials
      }
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: webSites
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: webSites
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

@description('The name of the web sites resource.')
output name string = webSites.name

@description('The resource ID of the deployed web sites resource.')
output resourceId string = webSites.id
