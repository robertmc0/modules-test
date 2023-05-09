/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'subscription'

@description('The location which test resources will be deployed to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'adb'

@description('The name to use for virtual network public subnet')
param publicSubnetName string = 'public-snet'

@description('The name to use for virtual network private subnet')
param privateSubnetName string = 'private-snet'

var minManagedResourceGroupName = '${shortIdentifier}-min-tst-${uniqueString(deployment().name, location)}-mrg'
var minManagedResourceGroupId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${minManagedResourceGroupName}'

var lckManagedResourceGroupName = '${shortIdentifier}-lck-tst-${uniqueString(deployment().name, location)}-mrg'
var lckManagedResourceGroupId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${lckManagedResourceGroupName}'

var diagsManagedResourceGroupName = '${shortIdentifier}-diags-tst-${uniqueString(deployment().name, location)}-mrg'
var diagsManagedResourceGroupId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${diagsManagedResourceGroupName}'

var maxManagedResourceGroupName = '${shortIdentifier}-max-tst-${uniqueString(deployment().name, location)}-mrg'
var maxManagedResourceGroupId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${maxManagedResourceGroupName}'

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource minResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'adb-min-tst-${uniqueString(deployment().name, location)}-rg'
  location: location
}

resource diagsResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'adb-diags-tst-${uniqueString(deployment().name, location)}-rg'
  location: location
}

resource lckResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'adb-lck-tst-${uniqueString(deployment().name, location)}-rg'
  location: location
}

resource maxResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'adb-max-tst-${uniqueString(deployment().name, location)}-rg'
  location: location
}

module minPrereqs 'main.test.prereqs.bicep' = {
  name: '${shortIdentifier}-tst-min-${uniqueString(deployment().name, location)}'
  scope: minResourceGroup
  params: {
    networkName: '${uniqueString(deployment().name, location)}-min-vnet'
    logAnalyticsName: '${uniqueString(deployment().name, location)}-min-law'
    storageName: '${uniqueString(deployment().name, location)}minstg'
    location: location
    publicSubnetName: '${uniqueString(deployment().name, location)}-min-${publicSubnetName}'
    privateSubnetName: '${uniqueString(deployment().name, location)}-min-${privateSubnetName}'
  }
}

module diagsPrereqs 'main.test.prereqs.bicep' = {
  name: '${shortIdentifier}-tst-diags-${uniqueString(deployment().name, location)}'
  scope: diagsResourceGroup
  params: {
    networkName: '${uniqueString(deployment().name, location)}-diags-vnet'
    logAnalyticsName: '${uniqueString(deployment().name, location)}-diags-law'
    storageName: '${uniqueString(deployment().name, location)}diagsstg'
    location: location
    publicSubnetName: '${uniqueString(deployment().name, location)}-diags-${publicSubnetName}'
    privateSubnetName: '${uniqueString(deployment().name, location)}-diags-${privateSubnetName}'
  }
}

module lckPrereqs 'main.test.prereqs.bicep' = {
  name: '${shortIdentifier}-tst-lck-${uniqueString(deployment().name, location)}'
  scope: lckResourceGroup
  params: {
    networkName: '${uniqueString(deployment().name, location)}-lck-vnet'
    logAnalyticsName: '${uniqueString(deployment().name, location)}-lck-law'
    storageName: '${uniqueString(deployment().name, location)}lckstg'
    location: location
    publicSubnetName: '${uniqueString(deployment().name, location)}-lck-${publicSubnetName}'
    privateSubnetName: '${uniqueString(deployment().name, location)}-lck-${privateSubnetName}'
  }
}

module maxPrereqs 'main.test.prereqs.bicep' = {
  name: '${shortIdentifier}-tst-max-${uniqueString(deployment().name, location)}'
  scope: maxResourceGroup
  params: {
    networkName: '${uniqueString(deployment().name, location)}-max-vnet'
    logAnalyticsName: '${uniqueString(deployment().name, location)}-max-law'
    storageName: '${uniqueString(deployment().name, location)}maxstg'
    location: location
    publicSubnetName: '${uniqueString(deployment().name, location)}-max-${publicSubnetName}'
    privateSubnetName: '${uniqueString(deployment().name, location)}-max-${privateSubnetName}'

  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module databricksMin '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-${shortIdentifier}'
  scope: minResourceGroup
  params: {
    name: '${uniqueString(deployment().name, location)}-min-${shortIdentifier}'
    location: location
    customPrivateSubnetName: '${uniqueString(deployment().name, location)}-min-${privateSubnetName}'
    customPublicSubnetName: '${uniqueString(deployment().name, location)}-min-${publicSubnetName}'
    customVirtualNetworkId: minPrereqs.outputs.networkResourceId
    managedResourceGroupId: minManagedResourceGroupId
  }
}

module databricksDiags '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-diags-${shortIdentifier}'
  scope: diagsResourceGroup
  params: {
    name: '${uniqueString(deployment().name, location)}-diags-${shortIdentifier}'
    location: location
    customPrivateSubnetName: '${uniqueString(deployment().name, location)}-diags-${privateSubnetName}'
    customPublicSubnetName: '${uniqueString(deployment().name, location)}-diags-${publicSubnetName}'
    customVirtualNetworkId: diagsPrereqs.outputs.networkResourceId
    managedResourceGroupId: diagsManagedResourceGroupId
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: diagsPrereqs.outputs.logAnalyticsResourceId
    diagnosticLogsRetentionInDays: 30
    diagnosticStorageAccountId: diagsPrereqs.outputs.storageResourceId
  }
}

module databricksLck '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-lck-${shortIdentifier}'
  scope: lckResourceGroup
  params: {
    name: '${uniqueString(deployment().name, location)}-lck-${shortIdentifier}'
    location: location
    customPrivateSubnetName: '${uniqueString(deployment().name, location)}-lck-${privateSubnetName}'
    customPublicSubnetName: '${uniqueString(deployment().name, location)}-lck-${publicSubnetName}'
    customVirtualNetworkId: lckPrereqs.outputs.networkResourceId
    managedResourceGroupId: lckManagedResourceGroupId
    resourcelock: 'CanNotDelete'
  }
}

module databricksMax '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-max-${shortIdentifier}'
  scope: maxResourceGroup
  params: {
    name: '${uniqueString(deployment().name, location)}-max-${shortIdentifier}'
    location: location
    sku: 'premium'
    tags: {
      owner: 'test user'
    }
    customVirtualNetworkId: maxPrereqs.outputs.networkResourceId
    customPrivateSubnetName: '${uniqueString(deployment().name, location)}-max-${privateSubnetName}'
    customPublicSubnetName: '${uniqueString(deployment().name, location)}-max-${publicSubnetName}'
    managedResourceGroupId: maxManagedResourceGroupId
    resourcelock: 'CanNotDelete'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: maxPrereqs.outputs.logAnalyticsResourceId
    diagnosticLogsRetentionInDays: 30
    diagnosticStorageAccountId: maxPrereqs.outputs.storageResourceId
  }
}
