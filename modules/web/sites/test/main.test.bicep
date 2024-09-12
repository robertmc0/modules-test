/*
** Configuration
*/

@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(4)
param shortIdentifier string = 'arn'

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
  name: '${logAnalyticsWorkspaceName}-test'
  location: location
}

// Add module for Application Insights

var applicationInsightsName = '${shortIdentifier}tstlaw${uniqueString(deployment().name, 'applicationInsights', location)}'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(deployment().name, 'vnet', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'defaultSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: [
            {
              name: 'appServiceDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// Test for Linux
var appServicePlanLinuxName = '${shortIdentifier}-tst-${uniqueString(deployment().name, 'linux', location)}'
resource appServicePlanLinux 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanLinuxName
  location: location
  kind: 'app'
  sku: {
    name: 'B1'
  }
  properties: {
    reserved: true
  }
}

var appServicePlanWinName = '${shortIdentifier}-tst-${uniqueString(deployment().name, 'win', location)}'
resource appServicePlanWin 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanWinName
  location: location
  kind: 'app'
  sku: {
    name: 'B1'
  }
}

var webSitesNameMinimum = '${shortIdentifier}-tst-website-min-linux-${uniqueString(deployment().name, 'min', location)}'

module webSitesMinimum '../main.bicep' = {
  name: webSitesNameMinimum
  params: {
    name: webSitesNameMinimum
    location: location
    serverFarmId: appServicePlanLinux.id
    applicationInsightsId: appInsights.id
    kind: 'app,linux'
    runtime: 'NODE|20-lts'
    appSettings: {
      Test: 'Test1'
    }
  }
}

var webSiteLinuxName = '${shortIdentifier}-tst-website-linux-${uniqueString(deployment().name, 'linux', location)}'

module webSite '../main.bicep' = {
  name: webSiteLinuxName
  params: {
    name: webSiteLinuxName
    location: location
    virtualNetworkSubnetId: virtualNetwork.properties.subnets[0].id
    serverFarmId: appServicePlanLinux.id
    applicationInsightsId: appInsights.id
    kind: 'app,linux'
    runtime: 'NODE|20-lts'
    appSettings: {
      Test: 'Test1'
      Test3__Setting: 'Test3'
    }
    allowedOrigins: allowedOrigins
    supportCredentials: supportCredentials
    enableDiagnostics: true
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    systemAssignedIdentity: true
    ipSecurityRestrictionsDefaultAction: 'Deny'
    ipSecurityRestrictions: [
      {
        name: 'Source-IP'
        action: 'Allow'
        ipAddress: '1.1.1.1/32'
      }
    ]
    vnetRouteAllEnabled: true
  }
}

//Test for Windows
var webSiteWinName = '${shortIdentifier}-tst-website-win-${uniqueString(deployment().name, 'win', location)}'

module webSiteWin '../main.bicep' = {
  name: webSiteWinName
  params: {
    name: webSiteWinName
    location: location
    virtualNetworkSubnetId: virtualNetwork.properties.subnets[0].id
    serverFarmId: appServicePlanWin.id
    applicationInsightsId: appInsights.id
    kind: 'app'
    runtime: 'DOTNET|6.0'
    appSettings: {
      Test: 'Test1'
      Section1__Setting: 'ABC'
    }
    allowedOrigins: allowedOrigins
    supportCredentials: supportCredentials
    enableDiagnostics: true
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    systemAssignedIdentity: true
    ipSecurityRestrictionsDefaultAction: 'Deny'
    ipSecurityRestrictions: [
      {
        name: 'Source-IP'
        action: 'Allow'
        ipAddress: '1.1.1.1/32'
      }
    ]
    vnetRouteAllEnabled: true
  }
}
