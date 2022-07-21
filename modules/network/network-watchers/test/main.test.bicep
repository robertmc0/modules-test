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
module networkWatcher '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-network-watcher'
  params: {
    name: '${shortIdentifier}-tst-nw-${uniqueString(deployment().name, 'networkWatcher', location)}'
    location: location
  }
}
