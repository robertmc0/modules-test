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

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${shortIdentifier}-tst-nsg-${uniqueString(deployment().name, 'networkSecurityGroup', location)}'
  location: location
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
    networkSecurityGroupId: nsg.id
    networkWatcherName: networkWatcher.name
    storageAccountId: storageAccount.id
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}
