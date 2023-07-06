/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/

targetScope = 'subscription'

@description('The resource name.')
param name string = 'mls-test-worskpace'

@description('The location which test resources will be deployed to')
param location string = 'australiaeast'

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource minResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'mls-min-tst-${uniqueString(deployment().name, location)}-rg'
  location: location
}

module minPrereqs 'main.test.prereqs.bicep' = {
  scope: minResourceGroup
  name: 'mls-min-tst-${uniqueString(deployment().name, location)}'
  params: {
    location: location
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/

module machienLearningServiceWorkspaceMin '../main.bicep' = {
  scope: minResourceGroup
  name: name
  params: {
    location: location
    name: name
    applicationInsightsResourceId: minPrereqs.outputs.applicationInsightsResourceId
    keyVaultResourceId: minPrereqs.outputs.keyVaultResourceId
    storageAccountResourceId: minPrereqs.outputs.storageAccountResourceId
    containerRegistryResourceId: minPrereqs.outputs.containerRegistryResourceId
    systemAssignedIdentity: true
  }
}
