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
resource logAnalyticsWorkspace1 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace1', location)}'
  location: location
}

resource logAnalyticsWorkspace2 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace2', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module sentinelMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-sent'
  params: {
    location: location
    workspaceId: logAnalyticsWorkspace1.id
  }
}

module sentinel '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-sent'
  params: {
    location: location
    workspaceId: logAnalyticsWorkspace2.id
    dataSources: [
      {
        name: 'LogicalDisk1'
        kind: 'WindowsPerformanceCounter'
        properties: {
          objectName: 'LogicalDisk'
          instanceName: '*'
          intervalSeconds: 360
          counterName: 'Avg Disk sec/Read'
        }
      }
    ]
    alertRules: [
      {
        name: 'mlrdp'
        kind: 'MLBehaviorAnalytics'
        properties: {
          enabled: true
          alertRuleTemplateName: '737a2ce1-70a3-4968-9e90-3e6aca836abf'
        }
      }
    ]
    connectors: [
      {
        kind: 'AzureSecurityCenter'
        properties: {
          subscriptionId: subscription().subscriptionId
          dataTypes: {
            alerts: {
              state: 'enabled'
            }
          }
        }
      }
    ]
  }
}
