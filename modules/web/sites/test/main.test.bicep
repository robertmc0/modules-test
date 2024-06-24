/*
** Configuration
*/

@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(4)
param shortIdentifier string = 'arn'

@description('Computed. Do not set.')
param deploymentStartTime string = utcNow()

@description('The resource ID for the target virtual network subnet.')
param virtualNetworkSubnetId string

@description('Required. The LinuxFxVersion to use for the web app.')
param isLinux bool = true

@description('Required. The runtime to use for the web app.')
param linuxFxVersion string = 'NODE|20-lts'

@description('Optional. Application Insights configuration for the app service sites.')
param appSettings array = [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: ''
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: ''
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~2'
  }
]


@description('Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345).')
param allowedOrigins array = [
        'http://example.com'
        'https://anotherexample.com'
]

@description('Gets or sets whether CORS requests with credentials are allowed. See https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials for more details.')
param supportCredentials bool = true


/*
** Prerequisites
*/
var logAnalyticsWorkspaceName = '${shortIdentifier}tstlaw${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${logAnalyticsWorkspaceName}${deploymentStartTime}'
  location: location
}

// Add module for Application Insights

var applicationInsightsName = '${shortIdentifier}tstlaw${uniqueString(deployment().name, 'applicationInsights', location)}'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  dependsOn: [
    logAnalyticsWorkspace
  ]
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    DisableLocalAuth: false
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
    SamplingPercentage: 100
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}



// Test for Linux

var appServicePlanLinuxMinimumName = '${shortIdentifier}-tst-linux-${uniqueString(deployment().name, 'appServicePlanLinuxMinimum', location)}'

module appServicePlanLinux '../../server-farms/main.bicep' = {
  name: appServicePlanLinuxMinimumName
  params: {
    name: appServicePlanLinuxMinimumName
    location: location
    skuName: 'P1v3'
    operatingSystem: 'linux'
    resourceLock: 'CanNotDelete'
  }
}

var webSitesNameMinimum = '${shortIdentifier}-tst-webSitesLinux-${uniqueString(deployment().name, 'webSitesMinimum', location)}'

module webSitesMinimum '../main.bicep' = {
  name: webSitesNameMinimum
  dependsOn: [
    appServicePlanLinux
  ]
  params: {
    name: webSitesNameMinimum
    location: location
    virtualNetworkSubnetId: virtualNetworkSubnetId
    serverFarmId: appServicePlanLinux.outputs.resourceId
    isLinux: isLinux
      linuxFxVersion: isLinux && !empty(linuxFxVersion) ? linuxFxVersion : null
      appSettings: [
        for setting in (appSettings ?? []): {
          name: setting.name
          value: setting.value
        }
      ]
        allowedOrigins: allowedOrigins
        supportCredentials: supportCredentials
  }
}

//Test for Windows
