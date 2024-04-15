param location string = resourceGroup().location
var apimSku = 'Standard'
var customEmails = [
  'john.smith@microsoft.com'
]

module logAnalyticsWorkspace '../../../operational-insights/workspaces/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-la'
  params: {
    name: '${uniqueString(deployment().name, location)}-la'
    location: location
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${uniqueString(deployment().name, location)}-appi'
  location: location
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
  }
  kind: 'web'
}

module apiManagementService '../../../api-management/service/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-apim-01'
  params: {
    name: '${uniqueString(deployment().name, location)}-apim-01'
    location: location
    sku: apimSku
    systemAssignedIdentity: true
    minApiVersion: '2019-12-01'
    skuCount: 1
    loggerHttpCorrelationProtocol: 'W3C'
    publisherEmail: 'john.smith@microsoft.com'
    publisherName: 'Arinco'
    applicationInsightsId: applicationInsights.id
  }
}

var targetResourceId = apiManagementService.outputs.resourceId
var profiles = [
  {
    name: 'DefaultAutoscaleProfile'
    capacity: {
      minimum: '1'
      default: '1'
      maximum: '4'
    }
    rules: [
      {
        metricTrigger: {
          metricName: 'Capacity'
          metricResourceUri: targetResourceId
          operator: 'GreaterThan'
          statistic: 'Average'
          threshold: 75
          timeAggregation: 'Average'
          timeGrain: 'PT5M'
          timeWindow: 'PT30M'
        }
        scaleAction: {
          cooldown: 'PT10M'
          direction: 'Increase'
          type: 'ChangeCount'
          value: '1'
        }
      }
      {
        metricTrigger: {
          metricName: 'Capacity'
          metricResourceUri: targetResourceId
          operator: 'LessThan'
          statistic: 'Average'
          threshold: 30
          timeAggregation: 'Average'
          timeGrain: 'PT5M'
          timeWindow: 'PT30M'
        }
        scaleAction: {
          cooldown: 'PT10M'
          direction: 'Decrease'
          type: 'ChangeCount'
          value: '1'
        }
      }
    ]
  }
]

module autoScaleSettings '../main.bicep' = if (apimSku == 'Standard' || apimSku == 'Premium') {
  name: '${uniqueString(deployment().name, location)}-ass'
  params: {
    location: location
    targetResourceId: targetResourceId
    customEmails: customEmails
    profiles: profiles
  }
}
