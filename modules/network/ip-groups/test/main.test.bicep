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
  application: 'bicep module'
}

/*======================================================================
TEST PREREQUISITES
======================================================================*/
var ipGroups = [
  {
    name: '${shortIdentifier}-tst-ipgrps1-${uniqueString(deployment().name, 'ipGroups', location)}'
    ipAddresses: [
      '172.10.2.4/32'
      '172.10.2.5/32'
      '172.10.2.6/32'
      '172.10.2.7/32'
    ]
  }
  {
    name: '${shortIdentifier}-tst-ipgrps2-${uniqueString(deployment().name, 'ipGroups', location)}'
    ipAddresses: [
      '10.50.2.4/32'
      '10.50.2.5/32'
      '10.50.2.6/32'
      '10.50.2.7/32'
    ]
  }
]

/*======================================================================
TEST EXECUTION
======================================================================*/
module ipGroupsMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-ip-groups'
  params: {
    name: '${shortIdentifier}-tst-ipgrps-min-${uniqueString(deployment().name, 'ipGroups', location)}'
    location: location
    ipAddresses: [
      '172.10.2.4/32'
      '172.10.2.5/32'
    ]
  }
}

module ipGroupsLoop '../main.bicep' = [for (ipGroup, i) in ipGroups: {
  name: '${uniqueString(deployment().name, location)}-loop${i}-ip-groups'
  params: {
    name: ipGroup.name
    tags: tags
    location: location
    ipAddresses: ipGroup.ipAddresses
    resourceLock: 'CanNotDelete'
  }
}]
