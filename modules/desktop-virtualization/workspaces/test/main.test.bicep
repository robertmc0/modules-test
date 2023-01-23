/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {
  environment: 'test'
}

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: '${shortIdentifier}-tst-hp-${uniqueString(deployment().name, 'hostPool', location)}'
  location: location
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
  }
}

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' = {
  name: '${shortIdentifier}-tst-ag-${uniqueString(deployment().name, 'applicationGroup', location)}'
  location: location
  properties: {
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostPool.id
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
resource diagnosticsEventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsEventHubNamespace', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module minWorkspace '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-wksp'
  params: {
    name: '${shortIdentifier}-tst-min-${uniqueString(deployment().name, 'workspace', location)}'
    location: location
    applicationGroupReferences: []
  }
}

module workspace '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-wksp'
  params: {
    name: '${shortIdentifier}-tst-${uniqueString(deployment().name, 'workspace', location)}'
    location: location
    tags: tags
    friendlyName: 'test workspace'
    workspaceDescription: 'workspace used for testing purposes'
    applicationGroupReferences: [
      applicationGroup.id
    ]
    publicNetworkAccess: 'Disabled'
  }
}
