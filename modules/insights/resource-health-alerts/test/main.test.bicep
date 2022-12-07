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
resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: '${shortIdentifier}-tst-action-group-${uniqueString(deployment().name, 'ag', location)}'
  location: 'global'
  properties: {
    groupShortName: '${shortIdentifier}-ag'
    enabled: true
  }
}

resource resourceAlertStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstalert${uniqueString(deployment().name, 'resourceAlertStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module resourceHealthAlertMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-resource-alert'
  params: {
    name: '${uniqueString(deployment().name, location)}-min-resource-alert'
    actionGroupIds: [
      actionGroup.id
    ]
  }
}

module resourceHealthAlert '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-resource-alert'
  params: {
    name: '${uniqueString(deployment().name, location)}-resource-alert'
    actionGroupIds: [
      actionGroup.id
    ]
    resourceTypes: [
      resourceAlertStorageAccount.id
    ]
  }
}
