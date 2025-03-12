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
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: '${shortIdentifier}-tst-evhns-${uniqueString(deployment().name, 'evhns', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module eventHub '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-evh'
  params: {
    name: '${shortIdentifier}-tst-evh-${uniqueString(deployment().name, 'evh', location)}'
    messageRetentionInDays: 1
    partitionCount: 2
    scope: eventHubNamespace.name
  }
}
