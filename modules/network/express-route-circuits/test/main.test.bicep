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
module expressRouteMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-er'
  params: {
    name: '${shortIdentifier}-tst-er-min-${uniqueString(deployment().name, 'expressRoute', location)}'
    location: location
    bandwidthInMbps: 100
    billingModel: 'MeteredData'
    peeringLocation: 'Melbourne'
    serviceProviderName: 'Optus'
  }
}

module expressRoute '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-er'
  params: {
    name: '${shortIdentifier}-tst-er-${uniqueString(deployment().name, 'expressRoute', location)}'
    location: location
    bandwidthInMbps: 100
    billingModel: 'MeteredData'
    peeringLocation: 'Melbourne'
    serviceProviderName: 'Optus'
    allowClassicOperations: true
    peeringConfig: {
      name: 'AzurePrivatePeering'
      peeringType: 'AzurePrivatePeering'
      peerASN: 5432
      primaryPeerAddressPrefix: '172.50.1.28/30'
      secondaryPeerAddressPrefix: '172.50.1.24/30'
      vlanId: 10
    }
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
