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
resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: '${shortIdentifier}-tst-action-group-${uniqueString(deployment().name, 'ag', location)}'
  location: 'global'
  properties: {
    groupShortName: '${shortIdentifier}-ag'
    enabled: true
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module serviceHealthAlertMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-service-alert'
  params: {
    name: '${uniqueString(deployment().name, location)}-min-service-alert'
    actionGroupIds: [
      actionGroup.id
    ]
  }
}

module serviceHealthAlert '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-service-alert'
  params: {
    name: '${uniqueString(deployment().name, location)}-service-alert'
    actionGroupIds: [
      actionGroup.id
    ]
    incidentTypes: [
      'Incident'
      'Security'
    ]
    regions: [
      'Australia East'
      'Australia Southeast'
    ]
    serviceNames: [
      'Azure Container Service'
      'Azure Firewall'
    ]
  }
}
