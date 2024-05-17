import { createApplicationInsightsTile, createAzureMonitorTile, createMiscellaneousTile } from '../functions.bicep'

/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/

@description('Optional. The location of the Azure resources. Defaults to "australiaeast".')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
@minLength(1)
@maxLength(3)
param shortIdentifier string = 'dsh'

var uniqueName = uniqueString(deployment().name, location)

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: '${shortIdentifier}-sb-tst-${uniqueName}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

var serviceBusMetricsGrouping = {
  dimension: 'EntityName'
  sort: 1
  top: 10
}

var serviceBusMetrics = [
  {
    resourceMetadata: {
      id: serviceBusNamespace.id
    }
    name: 'DeadletteredMessages'
    aggregationType: 4
    namespace: 'microsoft.servicebus/namespaces'
    metricVisualization: {
      displayName: 'Dead Letter Messages'
      resourceDisplayName: serviceBusNamespace.name
    }
  }
]

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${shortIdentifier}-ai-tst-${uniqueName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

var errorQuery = '''
union 
exceptions,
traces | where severityLevel == 3
| project timestamp,
          itemType = case(itemType == "trace", "Error", itemType == "exception", "Exception", "Unknown"),
          message = substring(iif(itemType == "exception", outerMessage, message), 0, 200),
          operation_Name, 
          cloud_RoleName
| project message, itemType, cloud_RoleName, timestamp
| order by timestamp desc
'''

/*======================================================================
TEST EXECUTION
======================================================================*/

module dashboard '../main.bicep' = {
  name: 'deploy_dashboard'
  params: {
    location: location
    name: '${shortIdentifier}-db-tst-${uniqueName}'
    tiles: [
      createApplicationInsightsTile('P1D', errorQuery, 'API Errors', 'Exceptions and error logs', appInsights.id)
      createAzureMonitorTile('Dead Lettered Messages', 'area', serviceBusMetrics, [], serviceBusMetricsGrouping)
    ]
  }
}
