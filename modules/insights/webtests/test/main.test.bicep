param location string = resourceGroup().location

// Standard names
module names '../../../naming/conventions/main.bicep' = {
  scope: subscription()
  name: '${uniqueString(deployment().name, location)}-names'
  params: {
    location: location
    prefixes: [
      'ar'
      '**location**'
      'tst'
    ]
    suffixes: [
      'adr'
    ]
  }
}

// App Insights
module logAnalytics '../../../operational-insights/workspaces/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-la'
  params: {
    location: location
    name: names.outputs.names.logAnalytics.name
  }
}

module appInsights '../../components/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-appi'
  params: {
    name: names.outputs.names.appInsights.name
    location: location
    workspaceResourceId: logAnalytics.outputs.resourceId
  }
}

// Action Groups
// TODO: Replace this with module
resource actionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: '${uniqueString(deployment().name, location)}-ag'
  location: 'global'
  properties: {
    enabled: true
    groupShortName: 'short-name'
    emailReceivers: [
      {
        emailAddress: 'drew.robson@arinco.com.au'
        name: '${uniqueString(deployment().name, location)}-email'
        useCommonAlertSchema: true
      }
    ]
  }
}

// Module to test
module webtest '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-webtest'
  params: {
    location: location
    appInsightsId: appInsights.outputs.resourceId
    serviceName: names.outputs.names.webApp.name
    pingTestUrl: 'https://github.com/arincoau'
    actionGroups: [actionGroup.id]
  }
}
