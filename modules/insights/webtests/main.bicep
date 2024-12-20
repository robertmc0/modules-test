metadata name = 'Web Test Module'
metadata description = 'This module deploys a Web Test (Microsoft.Insights/webtests) resource and an associated alert on failure.'
metadata owner = 'Arinco'

@description('ResourceId of target App Insights for Web Test.')
param appInsightsId string

@description('Name of the target service to monitor.')
param serviceName string

@description('Target URL for the Ping Test.')
param pingTestUrl string

@description('Array of ResourceIds of Actions Groups.')
param actionGroups array

@description('Optional. Location of resources.')
param location string = resourceGroup().location

@description('Optional. Response code for the GET Ping Web Test, defaulting to 200.')
param expectedResponseCode string = '200'

@description('Optional. Array of Web Test Locations as per https://learn.microsoft.com/en-us/previous-versions/azure/azure-monitor/app/monitor-web-app-availability#location-population-tags.')
param webTestLocations array = [
  'us-il-ch1-azr'
  'us-ca-sjc-azr'
  'apac-sg-sin-azr'
  'emea-gb-db3-azr'
  'emea-au-syd-edge'
]

@description('Optional. Frequency of Web Test execution.')
param webTestFrequency int = 300

@description('Optional. Timeout period for Web Test.')
param webTestTimeout int = 120

@description('Optional. Alert Severity.')
param alertSeverity int = 0

@description('Optional. Number of Failed Locations until Alert.')
param failedLocationCount int = length(webTestLocations) / 2 // Default to ~50%

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

resource pingWebTest 'Microsoft.Insights/webtests@2022-06-15' = {
  location: location
  tags: union(tags, { 'hidden-link:${appInsightsId}': 'Resource' })
  name: '${serviceName}-pingWebTest'
  kind: 'ping'
  properties: {
    SyntheticMonitorId: '${serviceName}-pingWebTest'
    Name: '${serviceName} - Availability Test'
    Description: 'A web test for performing a ping (HTTP GET) to test availability of the targeted web app'
    Enabled: true
    Frequency: webTestFrequency
    Timeout: webTestTimeout
    Kind: 'ping'
    RetryEnabled: true
    Locations: [
      for item in webTestLocations: {
        Id: item
      }
    ]
    Configuration: {
      WebTest: '<WebTest Name="${serviceName}-pingWebTest" Enabled="True" Timeout="${webTestTimeout}" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" PreAuthenticate="True" Proxy="default" StopOnError="False"><Items><Request Method="GET" Version="1.1" Url="${pingTestUrl}" ThinkTime="0" Timeout="${webTestTimeout}" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="${expectedResponseCode}" IgnoreHttpStatusCode="False" /></Items></WebTest>'
    }
  }
}

resource alert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${serviceName} - Failed Availability Test'
  location: 'global'
  tags: union(tags, { 'hidden-link:${appInsightsId}': 'Resource', 'hidden-link:${pingWebTest.id}': 'Resource' })
  properties: {
    description: 'Availability Ping Test for ${serviceName} has failed from at least ${failedLocationCount} test locations.'
    severity: alertSeverity
    enabled: true
    scopes: [
      appInsightsId
      pingWebTest.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
      webTestId: pingWebTest.id
      componentId: appInsightsId
      failedLocationCount: failedLocationCount
    }
    actions: [
      for item in actionGroups: {
        actionGroupId: item
      }
    ]
  }
}

@description('The resource ID of the deployed Web Test.')
output pingWebTestResourceId string = pingWebTest.id

@description('The name of the Web Test resource.')
output pingWebTestResourceName string = pingWebTest.name

@description('The resource ID of the deployed Alert.')
output alertResourceId string = alert.id

@description('The name of the Alert resource.')
output alertResourceName string = alert.name
