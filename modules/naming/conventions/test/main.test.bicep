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

/*======================================================================
TEST EXECUTION
======================================================================*/
module namingMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-naming-min'
  params: {
    location: location
    prefixes: [
      shortIdentifier
    ]
    suffixes: [
      'demomin'
    ]
  }
}

module naming '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-naming'
  params: {
    location: location
    prefixes: [
      shortIdentifier
      '**location**'
    ]
    suffixes: [
      'dev'
      'myapp'
    ]
  }
}

module resourceGroup 'main.test.rg.bicep' = {
  name: '${uniqueString(deployment().name, location)}-naming-rg'
  params: {
    location: location
    name: naming.outputs.names.resourceGroup.name
  }
}
