@description('Optional. Additional datacenter locations of the API Management service.')
param additionalLocations array = []

@description('Required. The name of the of the API Management service.')
param name string

@description('Optional. List of Certificates that need to be installed in the API Management service. Max supported certificates that can be installed is 10.')
@maxLength(10)
param certificates array = []

@description('Optional. Custom properties of the API Management service.')
param customProperties object = {}

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Property only valid for an API Management service deployed in multiple locations. This can be used to disable the gateway in master region.')
param disableGateway bool = false

@description('Optional. Property only meant to be used for Consumption SKU Service. This enforces a client certificate to be presented on each request to the gateway. This also enables the ability to authenticate the certificate in the policy on the gateway.')
param enableClientCertificate bool = false

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. Custom hostname configuration of the API Management service.')
param hostnameConfigurations array = []

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Limit control plane API calls to API Management service with version equal to or newer than this value.')
param minApiVersion string = ''

@description('Optional. The notification sender email address for the service.')
param notificationSenderEmail string = 'apimgmt-noreply@mail.windowsazure.com'

@description('Required. The email address of the owner of the service.')
param publisherEmail string

@description('Required. The name of the owner of the service.')
param publisherName string

@description('Optional. Undelete API Management Service if it was previously soft-deleted. If this flag is specified and set to True all other properties will be ignored.')
param restore bool = false

@description('Optional. The pricing tier of this API Management service.')
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('Optional. The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int = 1

@description('Optional. The full resource ID of a subnet in a virtual network to deploy the API Management service in.')
param subnetResourceId string = ''

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. The type of VPN in which API Management service needs to be configured in. None (Default Value) means the API Management service is not part of any Virtual Network, External means the API Management deployment is set up inside a Virtual Network having an internet Facing Endpoint, and Internal means that API Management deployment is setup inside a Virtual Network having an Intranet Facing Endpoint only.')
@allowed([
  'None'
  'External'
  'Internal'
])
param virtualNetworkType string = 'None'

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. A list of availability zones denoting where the resource needs to come from.')
param zones array = []

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'GatewayLogs'
])
param diagnosticLogCategoriesToEnable array = [
  'GatewayLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. Named values.')
param namedValues array = []

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

@description('Optional. Resource ID of the application insights resource.')
param applicationInsightsId string

@description('Optional. The sample rate for the application insights logger.')
param loggerSamplingRate int = 10

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

var applicationInsights = reference(applicationInsightsId,'2020-02-02', 'Full')

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource apiManagementService 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: skuCount
  }
  zones: zones
  identity: identity
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    notificationSenderEmail: notificationSenderEmail
    hostnameConfigurations: hostnameConfigurations
    additionalLocations: additionalLocations
    customProperties: customProperties
    certificates: certificates
    enableClientCertificate: enableClientCertificate ? true : null
    disableGateway: disableGateway
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: !empty(subnetResourceId) ? json('{"subnetResourceId": "${subnetResourceId}"}') : null
    apiVersionConstraint: !empty(minApiVersion) ? json('{"minApiVersion": "${minApiVersion}"}') : null
    restore: restore
  }
}

resource nameValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = [for namedValue in namedValues: {
  name: '${namedValue.displayName}'
  properties: {
    displayName: namedValue.displayName
    keyVault: contains(namedValue, 'keyVault') ? namedValue.keyVault : null
    secret: contains(namedValue, 'secret') ? namedValue.secret : false
    value: contains(namedValue, 'value') ? namedValue.value : null
  }
  parent: apiManagementService
}]

resource loggerNameValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: 'Logger-Credentials'
  properties: {
    displayName: 'Logger-Credentials'
    secret: true
    value: applicationInsights.properties.InstrumentationKey
  }
  parent: apiManagementService
}

resource portalSetting 'Microsoft.ApiManagement/service/portalsettings@2021-08-01' = {
  name: 'signin'
  properties: {
    enabled: true // Redirect Anonymous users to the Sign-In page.
  }
  parent: apiManagementService
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  name: 'applicationInsights'
  properties: {
    loggerType:  'applicationInsights'
    description: 'Application Insights Logger'
    credentials: {
      instrumentationKey: '{{Logger-Credentials}}' // refer to named value to prevent APIM generating a named value on every deployment
    }
    resourceId: applicationInsightsId
  }
  parent: apiManagementService
  dependsOn: [
    loggerNameValue
  ]
}

resource apimLoggerSettings 'Microsoft.ApiManagement/service/diagnostics@2021-08-01' = {
  name: 'applicationInsightsLoggerSettings'
  properties: {
    alwaysLog: 'allErrors'
    loggerId: apimLogger.id
    sampling: {
      samplingType: 'fixed'
      percentage: loggerSamplingRate
    }
  }
  parent: apiManagementService
}

resource apiManagementService_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${apiManagementService.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: apiManagementService
}

resource apiManagementService_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
    logAnalyticsDestinationType: 'Dedicated'
  }
  scope: apiManagementService
}

@description('The name of the API management service')
output name string = apiManagementService.name

@description('The resource ID of the API management service')
output resourceId string = apiManagementService.id

@description('The resource group the API management service was deployed into')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(apiManagementService.identity, 'principalId') ? apiManagementService.identity.principalId : ''
