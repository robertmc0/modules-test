/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource networkWatcher 'Microsoft.Network/networkWatchers@2022-01-01' = {
  name: '${shortIdentifier}-tst-nw-${uniqueString(deployment().name, 'networkWatcher', location)}'
  location: location
  properties: {}
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet1-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tststor${uniqueString(deployment().name, 'storageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module flowLog '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-flow-log'
  params: {
    name: '${uniqueString(deployment().name, location)}flowlog'
    location: location
    targetResourceId: vnet.id
    networkWatcherName: networkWatcher.name
    storageAccountId: storageAccount.id
    enableTrafficAnalytics: true
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}
