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
TEST EXECUTION
======================================================================*/
module userAssignedIdentity '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-umi'
  params: {
    name: '${shortIdentifier}tst-umi-${uniqueString(deployment().name, 'userAssignedIdentities', location)}'
    location: location
    resourceLock: 'CanNotDelete'
  }
}
