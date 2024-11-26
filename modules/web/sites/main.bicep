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

@description('Kind of web site.')
@allowed([
  'api'
  'api,linux'
  'app'
  'app,linux'
  'functionapp'
  'functionapp,linux'
])
param kind string

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

@description('Optional. Site redundancy mode.')
@allowed([
  'ActiveActive'
  'Failover'
  'GeoRedundant'
  'Manual'
  'None'
])
param redundancyMode string = 'None'

@description('Optional. The resource ID for the target virtual network subnet.')
param virtualNetworkSubnetId string = ''

@description('Optional. Virtual Network Route All enabled. This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied.')
param vnetRouteAllEnabled bool = true

@description('Optional. Allow or block all public traffic.')
param publicNetworkAccess bool = true

@description('Optional. Identity to use for Key Vault Reference authentication.')
@allowed([
  'SystemAssigned'
  'UserAssigned'
])
param keyVaultReferenceIdentity string = empty(userAssignedIdentities) ? 'SystemAssigned' : 'UserAssigned'

@description('Optional. Azure API management settings linked to the app.')
param apiManagementConfig string = ''

@description('Resource ID of the application insights resource.')
param applicationInsightsId string

@description('Optional. Runtime type and version in the format TYPE|VERSION. Defaults to DOTNET|8.0')
@metadata({
  // https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#valid-linuxfxversion-values
  // https://learn.microsoft.com/en-us/azure/azure-functions/supported-languages?tabs=isolated-process%2Cv4&pivots=programming-language-powershell#language-support-details
  // https://learn.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide
  runtime: [
    // entries without comments 'should' work on windows and linux, for api/app/functionapp alike
    'DOCKER|<image reference e.g. mcr.microsoft.com/azure-app-service/windows/parkingpage:latest>'
    'DOTNET|6.0' // for functionapps on linux (yeah, really), and anything on windows
    'DOTNET|7.0' // for functionapps on linux (yeah, really), and anything on windows
    'DOTNETCORE|6.0' // for (api|app),linux
    'DOTNETCORE|7.0' // for (api|app),linux
    'DOTNETCORE|8.0' // for (api|app),linux
    'DOTNET-ISOLATED|4.8'
    'DOTNET-ISOLATED|6.0'
    'DOTNET-ISOLATED|7.0'
    'DOTNET-ISOLATED|8.0'
    'GO|1.19' // for linux
    'JAVA|8'
    'JAVA|11'
    'JAVA|17'
    'NODE|14'
    'NODE|16'
    'NODE|18'
    'NODE|18-lts'
    'NODE|20'
    'NODE|20-lts'
    'PHP|8.0'
    'PHP|8.1'
    'PHP|8.2'
    'POWERSHELL|7.2'
    'PYTHON|3.7' // for linux
    'PYTHON|3.8' // for linux
    'PYTHON|3.9' // for linux
    'PYTHON|3.10' // for linux
    'PYTHON|3.11' // for linux
  ]
})
param runtime string = contains(kind, 'linux') && !contains(kind, 'function') ? 'DOTNETCORE|8.0' : 'DOTNET|8.0'

@description('Optional. Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345).')
param allowedOrigins array = []

@description('Optional. IP security restrictions for main.')
@metadata({
  sampleInput: [
    {
      action: 'Allow or Deny access for this IP range.'
      description: 'IP restriction rule description.'
      headers: {
        // Arrays of up to 8 strings
        'X-Forwarded-Host': []
        'X-Forwarded-For': []
        'X-Azure-FDID': []
        'X-FD-HealthProbe': []
      }
      ipAddress: 'CIDR or Azure Service Tag'
      name: 'IP restriction rule name.'
      priority: 999 // Priority of IP restriction rule.
      tag: 'Default or ServiceTag or XffProxy'
      vnetSubnetResourceId: 'Virtual network resource id.'
    }
    {
      action: 'Allow'
      description: 'Allow traffic from our specific Front Door instance.'
      headers: {
        'X-Azure-FDID': [
          '12345678-1234-1234-1234-123456789012'
        ]
      }
      ipAddress: 'AzureFrontDoor.Backend'
      name: 'Allow Front Door'
      priority: 100
      tag: 'ServiceTag'
    }
  ]
})
param ipSecurityRestrictions array = []

@description('Optional. Default action for main access restriction if no rules are matched.')
@allowed([
  'Allow'
  'Deny'
])
param ipSecurityRestrictionsDefaultAction string = 'Allow'

@description('Optional. IP security restrictions for scm.')
@metadata({
  sampleInput: [
    {
      action: 'Allow or Deny access for this IP range.'
      description: 'IP restriction rule description.'
      headers: {
        // Arrays of up to 8 strings
        'X-Forwarded-Host': []
        'X-Forwarded-For': []
        'X-Azure-FDID': []
        'X-FD-HealthProbe': []
      }
      ipAddress: 'CIDR or Azure Service Tag'
      name: 'IP restriction rule name.'
      priority: 999 // Priority of IP restriction rule.
      tag: 'Default or ServiceTag or XffProxy'
      vnetSubnetResourceId: 'Virtual network resource id.'
    }
    {
      action: 'Allow'
      description: 'Allow traffic from our specific Front Door instance.'
      headers: {
        'X-Azure-FDID': [
          '12345678-1234-1234-1234-123456789012'
        ]
      }
      ipAddress: 'AzureFrontDoor.Backend'
      name: 'Allow Front Door'
      priority: 100
      tag: 'ServiceTag'
    }
  ]
})
param scmIpSecurityRestrictions array = []

@description('Optional. Default action for scm access restriction if no rules are matched.')
@allowed([
  'Allow'
  'Deny'
])
param scmIpSecurityRestrictionsDefaultAction string = 'Allow'

@description('Optional. IP security restrictions for scm to use main.')
param scmIpSecurityRestrictionsUseMain bool = true

@description('Optional. Gets or sets whether CORS requests with credentials are allowed. See https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials for more details.')
param supportCredentials bool = false

@description('Optional. Determines if instances of thhe site are always running, even when idle.')
param alwaysOn bool = false

@description('Optional. Enable sending session affinity cookies, which route client requests in the same session to the same instance.')
param clientAffinityEnabled bool = false

@description('Optional. Application settings to be applied to web site.')
@metadata({
  key1: 'value1'
  key2: 'value2'
})
param appSettings object = {}

@description('Optional. Array of Connection Strings.')
@metadata({
  sampleInput: [
    {
      name: 'connectionstring'
      connectionString: 'Data Source=tcp:{sqlFQDN},1433;Initial Catalog={sqlDBName};User Id={sqlLogin};Password=\'{sqlLoginPassword}\';'
      type: 'SQLAzure'
    }
  ]
})
param connectionStrings array = []

// https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#functions_extension_version
@description('Optional. The version of the Functions runtime that hosts your function app.')
param functionsExtensionVersion string = '~4'

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

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

@description('Optional. Names of the deployment slots.')
param deploymentSlotNames array = []

var diagnosticsName = toLower('${webSites.name}-dgs')

var diagnosticsLogs = [
  for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
    categoryGroup: categoryGroup
    enabled: true
  }
]

var diagnosticsMetrics = [
  for metric in diagnosticMetricsToEnable: {
    category: metric
    timeGrain: null
    enabled: true
  }
]

var isLinux = contains(kind, 'linux')
var isFunctionApp = contains(kind, 'functionapp')

var identityType = systemAssignedIdentity
  ? (!empty(userAssignedIdentities) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
  : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None'
  ? {
      type: identityType
      userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
    }
  : null

var appSettingsApplicationInsights = !empty(applicationInsightsId)
  ? {
      APPLICATIONINSIGHTS_CONNECTION_STRING: reference(applicationInsightsId, '2020-02-02').ConnectionString
      ApplicationInsightsAgent_EXTENSION_VERSION: isLinux ? '~3' : '~2'
      InstrumentationEngine_EXTENSION_VERSION: '~1'
      XDT_MicrosoftApplicationInsights_BaseExtensions: '~1'
      XDT_MicrosoftApplicationInsights_Mode: 'recommended'
    }
  : {}

@description('Optional. The language worker runtime to load in the app.')
var runtimeLanguage = toLower(first(split(runtime, '|')))

@description('Optional. The language worker runtime to load in the app.')
var runtimeVersion = last(split(runtime, '|'))

// Most things on Windows need a default netFrameworkVersion too (v8.0 LTS)
var netFrameworkVersion = startsWith(runtimeLanguage, 'dotnet') ? 'v${runtimeVersion}' : 'v8.0'

// Allow for NODE|18 and NODE|18-lts style version parameters
var nodeVersion = runtimeLanguage == 'node' ? '~${first(split(runtimeVersion, '-'))}' : ''

var appSettingsAppInsightsDotnet = startsWith(runtimeLanguage, 'dotnet')
  ? {
      XDT_MicrosoftApplicationInsights_PreemptSdk: '1'
    }
  : {}

var appSettingsFunctions = isFunctionApp
  ? {
      FUNCTIONS_EXTENSION_VERSION: functionsExtensionVersion
      FUNCTIONS_WORKER_RUNTIME: runtimeLanguage
    }
  : {}

var appSettingsFinal = union(
  appSettings,
  appSettingsAppInsightsDotnet,
  appSettingsApplicationInsights,
  appSettingsFunctions
)

resource webSites 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  kind: kind
  identity: identity
  tags: tags
  properties: {
      serverFarmId: serverFarmId
      httpsOnly: true
      clientAffinityEnabled: clientAffinityEnabled
      redundancyMode: redundancyMode
      virtualNetworkSubnetId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null
      reserved: isLinux
      publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'    
    }

  // security requirements
  resource basicAuthFtp 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource basicAuthScm 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: appSettingsFinal
  }

  resource configWeb 'config' = {
    name: 'web'
    properties: {
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      ftpsState: 'Disabled'
      alwaysOn: alwaysOn
      connectionStrings: !empty(connectionStrings) ? connectionStrings : null
      keyVaultReferenceIdentity: keyVaultReferenceIdentity
      linuxFxVersion: isLinux ? runtime : ''
      windowsFxVersion: runtimeLanguage == 'docker' && !isLinux ? runtime : ''
      netFrameworkVersion: isLinux || empty(netFrameworkVersion) ? null : netFrameworkVersion
      nodeVersion: isLinux || empty(nodeVersion) ? null : nodeVersion
      ipSecurityRestrictions: ipSecurityRestrictions
      ipSecurityRestrictionsDefaultAction: ipSecurityRestrictionsDefaultAction
      scmIpSecurityRestrictions: scmIpSecurityRestrictions
      scmIpSecurityRestrictionsDefaultAction: scmIpSecurityRestrictionsDefaultAction
      scmIpSecurityRestrictionsUseMain: scmIpSecurityRestrictionsUseMain
      apiManagementConfig: !empty(apiManagementConfig)
        ? {
            id: apiManagementConfig
          }
        : null
      cors: {
        allowedOrigins: allowedOrigins
        supportCredentials: supportCredentials
      }
      vnetRouteAllEnabled: vnetRouteAllEnabled
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: webSites
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: webSites
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId)
      ? null
      : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

#disable-next-line BCP081
resource stagingSlots 'Microsoft.Web/sites/slots@2024-04-01' = [for slot in deploymentSlotNames: {
  name: '${slot}'
  parent: webSites
  location: location
  properties: {
      serverFarmId: serverFarmId
      httpsOnly: true
      clientAffinityEnabled: clientAffinityEnabled
      redundancyMode: redundancyMode
      virtualNetworkSubnetId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null
      reserved: isLinux
      publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'  
    }
}]

@description('The name of the web sites resource.')
output name string = webSites.name

@description('The resource ID of the deployed web sites resource.')
output resourceId string = webSites.id