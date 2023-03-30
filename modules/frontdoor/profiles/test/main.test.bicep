/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The location to deploy resources to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
@minLength(1)
@maxLength(3)
param companyShortName string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${companyShortName}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${companyShortName}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
var uniqueName = uniqueString(deployment().name, 'global')

module frontDoorMinimum '../main.bicep' = {
  name: '${uniqueName}-min-module'
  params: {
    name: '${uniqueName}-min-afd'
    skuName: 'Standard_AzureFrontDoor'
  }
}

module frontDoorStd '../main.bicep' = {
  name: '${uniqueName}-std-module'
  params: {
    name: '${uniqueName}-std-afd'
    skuName: 'Standard_AzureFrontDoor'
    originResponseTimeoutSeconds: 60
    resourceLock: 'CanNotDelete'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
}
