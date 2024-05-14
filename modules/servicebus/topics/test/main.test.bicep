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
var serviceBusNamespaceName = '${shortIdentifier}-sbn-${uniqueString(deployment().name, 'servicebus', location)}'

module servicebusMin '../../namespaces/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-sbn'
  params: {
    name: serviceBusNamespaceName
    location: location
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/

module topic '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-topic'
  params: {
    name: '${uniqueString(deployment().name, location)}-topic'
    autoDeleteOnIdle: 'PT5M'
    defaultMessageTimeToLive: 'PT5M'
    servicebusNamespaceName: serviceBusNamespaceName
  }
  dependsOn: [
    servicebusMin
  ]
}
