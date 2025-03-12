@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
}

@description('The name of the deployed Log Analytics Workspace.')
output name string = logAnalyticsWorkspace.name

@description('The resource ID of the deployed Log Analytics Workspace.')
output resourceId string = logAnalyticsWorkspace.id
