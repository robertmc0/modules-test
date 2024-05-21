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
var serviceBusNamespaceName = '${shortIdentifier}-sbn-servicebustest-aue'

/*======================================================================
TEST EXECUTION
======================================================================*/

module subscription '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-queue'
  params: {
    name: '${uniqueString(deployment().name, location)}-queue'
    autoDeleteOnIdle: 'PT5M'
    defaultMessageTimeToLive: 'PT5M'
    maxDeliveryCount: 1
    servicebusNamespaceName: serviceBusNamespaceName
  }
}
