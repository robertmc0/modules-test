/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'subscription'

@description('Optional. The geo-location where the resource lives.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

var roleDefintionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor role

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${shortIdentifier}-tst-rg-${uniqueString(deployment().name, 'rg', location)}'
  location: location
}

module userIdentity 'main.test.prereqs.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${uniqueString(deployment().name, location)}-userIdentity'
  params: {
    name: '${shortIdentifier}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
    location: location
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module roleAssignmentSub '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-role'
  params: {
    principalId: userIdentity.outputs.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefintionId)
  }
}
