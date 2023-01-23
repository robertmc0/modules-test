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
module minApplicationGroup '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-ag'
  params: {
    name: '${shortIdentifier}-tst-min-ag-${uniqueString(deployment().name, 'applicationGroup', location)}'
    location: location
    applicationGroupType: 'RemoteApp'
    hostPoolArmPath: hostPool.id
  }
}

module desktopApplicationGroup '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-dsktp-ag'
  params: {
    name: '${shortIdentifier}-tst-dsktp-ag-${uniqueString(deployment().name, 'applicationGroup', location)}'
    friendlyName: 'test desktop application group'
    location: location
    tags: tags
    applicationGroupDescription: 'desktop application group used for test deployments'
    applicationGroupType: 'Desktop'
    hostPoolArmPath: hostPool.id
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    resourceLock: 'CanNotDelete'
  }
}

module remoteAppApplicationGroup '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-ra-ag'
  params: {
    name: '${shortIdentifier}-tst-ra-ag-${uniqueString(deployment().name, 'applicationGroup', location)}'
    friendlyName: 'test remoteapp application group'
    location: location
    tags: tags
    applicationGroupDescription: 'remoteapp application group used for test deployments'
    applicationGroupType: 'RemoteApp'
    hostPoolArmPath: hostPool.id
    remoteApps: [
      {
        name: 'FileExplorer'
        friendlyName: 'File Explorer'
        applicationType: 'InBuilt'
        filePath: 'c:\\windows\\explorer.exe'
        commandLineSetting: 'Allow'
      }
    ]
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    resourceLock: 'CanNotDelete'
  }
}
