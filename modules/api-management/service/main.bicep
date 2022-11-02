@description('Optional. Additional datacenter locations of the API Management service.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2021-08-01/service?tabs=bicep#additionallocation'
  example: {
    disableGateway: false
    location: 'string'
    publicIpAddressId: 'string'
    sku: {
      capacity: 1
      name: 'string'
    }
    virtualNetworkConfiguration: {
      subnetResourceId: 'string'
    }
    zones: [
      'string'
    ]
  }
})
param additionalLocations array = []

@description('Optional. List of Certificates that need to be installed in the API Management service. Max supported certificates that can be installed is 10.')
@maxLength(10)
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2021-08-01/service?tabs=bicep#certificateconfiguration'
  example: {
    certificate: {
      expiry: 'string'
      subject: 'string'
      thumbprint: 'string'
    }
    certificatePassword: 'string'
    encodedCertificate: 'string'
    storeName: 'string'
  }
})
param certificates array = []

@description('Optional. Custom properties of the API Management service.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2021-08-01/service?tabs=bicep#apimanagementserviceproperties'
  parameter: 'customProperties'
})
param customProperties object = {}

@description('Optional. Property only valid for an API Management service deployed in multiple locations. This can be used to disable the gateway in master region.')
param disableGateway bool = false

@description('Optional. Property only meant to be used for Consumption SKU Service. This enforces a client certificate to be presented on each request to the gateway. This also enables the ability to authenticate the certificate in the policy on the gateway.')
param enableClientCertificate bool = false

@description('Optional. Custom hostname configuration of the API Management service.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2021-08-01/service?tabs=bicep#hostnameconfiguration'
  example: {
    certificate: {
      expiry: 'string'
      subject: 'string'
      thumbprint: 'string'
    }
    certificatePassword: 'string'
    certificateSource: 'string'
    certificateStatus: 'string'
    defaultSslBinding: false
    encodedCertificate: 'string'
    hostName: 'string'
    identityClientId: 'string'
    keyVaultId: 'string'
    negotiateClientCertificate: false
    type: 'string'
  }
})
param hostnameConfigurations array = []

@description('Location for all Resources.')
param location string

@description('Optional. Limit control plane API calls to API Management service with version equal to or newer than this value.')
param minApiVersion string = ''

@description('The name of the of the API Management service.')
param name string

@description('Optional. Named values.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2021-08-01/service/namedvalues?tabs=bicep#namedvaluecreatecontractpropertiesornamedvaluecontractproperties'
  example: {
    displayName: 'string'
    keyVault: {
      identityClientId: 'string'
      secretIdentifier: 'string'
    }
    secret: false
    tags: [
      'string'
    ]
    value: 'string'
  }
})
param namedValues array = []

@description('Optional. The notification sender email address for the service.')
param notificationSenderEmail string = 'apimgmt-noreply@mail.windowsazure.com'

@description('The email address of the owner of the service.')
param publisherEmail string

@description('The name of the owner of the service.')
param publisherName string

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param resourcelock string = 'NotSpecified'

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

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. The ID(s) to assign to the resource.')
@metadata({
  example: {
    '/subscriptions/<subscription>/resourceGroups/<rgp>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-umi': {}
  }
})
param userAssignedIdentities object = {}

@description('Optional. The type of VPN in which API Management service needs to be configured in. None (Default Value) means the API Management service is not part of any Virtual Network, External means the API Management deployment is set up inside a Virtual Network having an internet Facing Endpoint, and Internal means that API Management deployment is setup inside a Virtual Network having an Intranet Facing Endpoint only.')
@allowed([
  'None'
  'External'
  'Internal'
])
param virtualNetworkType string = 'None'

@description('Optional- must be provided with internal or external network type. The full resource ID of an Azure Public IP he public IP address resource is required when setting up the virtual network for either external or internal access. With an internal virtual network, the public IP address is used only for management operations.')
param publicIpAddressId string = ''

@description('Optional. A list of availability zones denoting where the resource needs to come from.')
@metadata({
  zones: [ '1', '2' ]
})
param zones array = []

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

@description('Resource ID of the application insights resource.')
param applicationInsightsId string

@description('Optional. The sample rate for the application insights logger. Defaults to 10%')
param loggerSamplingRate int = 10

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

var lockName = toLower('${apiManagementService.name}-${resourcelock}-lck')

var diagnosticsName = toLower('${apiManagementService.name}-dgs')

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

var applicationInsights = reference(applicationInsightsId, '2020-02-02', 'Full')

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
    publicIpAddressId: !empty(publicIpAddressId) ? publicIpAddressId : null
    apiVersionConstraint: !empty(minApiVersion) ? json('{"minApiVersion": "${minApiVersion}"}') : null
    restore: restore
  }
}

resource nameValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = [for namedValue in namedValues: {
  parent: apiManagementService
  name: '${namedValue.displayName}'
  properties: {
    displayName: namedValue.displayName
    keyVault: contains(namedValue, 'keyVault') ? namedValue.keyVault : null
    secret: contains(namedValue, 'secret') ? namedValue.secret : false
    value: contains(namedValue, 'value') ? namedValue.value : null
  }
}]

resource loggerNameValue 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementService
  name: 'Logger-Credentials'
  properties: {
    displayName: 'Logger-Credentials'
    secret: true
    value: applicationInsights.properties.InstrumentationKey
  }
}

resource portalSetting 'Microsoft.ApiManagement/service/portalsettings@2021-08-01' = {
  parent: apiManagementService
  name: 'signin'
  properties: {
    enabled: true // Redirect Anonymous users to the Sign-In page.
  }
}

resource logger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  parent: apiManagementService
  name: 'applicationInsights'
  properties: {
    loggerType: 'applicationInsights'
    description: 'Application Insights Logger'
    credentials: {
      instrumentationKey: '{{Logger-Credentials}}' // refer to named value to prevent APIM generating a named value on every deployment
    }
    resourceId: applicationInsightsId
  }
  dependsOn: [
    loggerNameValue
  ]
}

resource loggerSettings 'Microsoft.ApiManagement/service/diagnostics@2021-08-01' = {
  parent: apiManagementService
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    loggerId: logger.id
    sampling: {
      samplingType: 'fixed'
      percentage: loggerSamplingRate
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: apiManagementService
  name: lockName
  properties: {
    level: resourcelock
    notes: resourcelock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: apiManagementService
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

@description('The name of the API management service')
output name string = apiManagementService.name

@description('The resource ID of the API management service')
output resourceId string = apiManagementService.id

@description('The resource group the API management service was deployed into')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(apiManagementService.identity, 'principalId') ? apiManagementService.identity.principalId : ''
