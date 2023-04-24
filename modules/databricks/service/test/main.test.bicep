/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'subscription'

@description('The location which test resources will be deployed to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('The name to use for virtual network public subnet')
param publicSubnetName string = 'public-snet'

@description('The name to use for virtual network private subnet')
param privateSubnetName string = 'private-snet'

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${shortIdentifier}-tst-rg-${uniqueString(deployment().name, 'resourceGroup', location)}'
  location: location
}

//This is a dumb hack, ADB resource wants a resource ID for deployment, but the Resource can't be created.
resource managedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: '${shortIdentifier}-tst-mrg-${uniqueString(deployment().name, 'resourceGroup', location)}'
}

module virtualNetwork 'main.test.prereqs.bicep' = {
  name: '${shortIdentifier}-tst-nwk-${uniqueString(deployment().name, 'resourceGroup', location)}'
  scope: az.resourceGroup(resourceGroup.name)
  params: {
    name: '${uniqueString(deployment().name, location)}-vnet'
    location: resourceGroup.location
    publicSubnetName: '${uniqueString(deployment().name, location)}-${publicSubnetName}'
    privateSubnetName: '${uniqueString(deployment().name, location)}-${privateSubnetName}'
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module databricks '../main.bicep' = {
  scope: az.resourceGroup(resourceGroup.name)
  name: 'adb-${uniqueString(deployment().name, location)}'
  params: {
    name: '${uniqueString(deployment().name, location)}-adb'
    location: resourceGroup.location
    customPrivateSubnetName: '${uniqueString(deployment().name, location)}-${privateSubnetName}'
    customPublicSubnetName: '${uniqueString(deployment().name, location)}-${publicSubnetName}'
    customVirtualNetworkId: virtualNetwork.outputs.resourceId
    managedResourceGroupId: managedResourceGroup.id
  }
}
