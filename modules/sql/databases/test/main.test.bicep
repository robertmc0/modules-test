// ========== //
// Parameters //
// ========== //

@description('Optional. The location to deploy resources to')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
param serviceShort string = 'db'

// ========== //
// Test Setup //
// ========== //

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: 'example-law-${serviceShort}-01'
  location: location
}

// Create a diagnostics setting object to use for all resources
var diagSettings = {
  name: 'diag-log'
  workspaceId: logAnalyticsWorkspace.id
  storageAccountId: ''
  eventHubAuthorizationRuleId: ''
  eventHubName: ''
  enableLogs: true
  enableMetrics: false
  retentionPolicy: {    
    days: 0
    enabled: false
  }
}

// ============== //
// Test Execution //
// ============== //

module azureSqlDatabase '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-sqldatabase'
  params: {
    location: location
    sqlServerName: 'example-dev-sql'
    databaseName: 'example-dev-db'
    skuType: 'Standard'
    skuCapacity: 10
    diagSettings: diagSettings
    maxDbSize: 10737418240
    enableResourceLock: false
  }
}
