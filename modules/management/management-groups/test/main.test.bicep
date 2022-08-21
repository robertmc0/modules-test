/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'tenant'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST EXECUTION
======================================================================*/
module managementGroupMinimum '../main.bicep' = {
  name: '${uniqueString(tenant().tenantId, deployment().name)}-min-mg'
  params: {
    name: '${shortIdentifier}-tst-mg-min-${uniqueString(deployment().name, 'managementGroups', tenant().displayName)}'
    displayName: '${shortIdentifier}-tst-mg-min'
  }
}

module managementGroup '../main.bicep' = {
  name: '${uniqueString(tenant().tenantId, deployment().name)}-mg'
  params: {
    name: '${shortIdentifier}-tst-mg-${uniqueString(deployment().name, 'managementGroups', tenant().displayName)}'
    displayName: '${shortIdentifier}-tst-mg'
    parent: managementGroupMinimum.outputs.resourceId
  }
}
