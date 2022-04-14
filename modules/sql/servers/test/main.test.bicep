// ========== //
// Parameters //
// ========== //

@description('Optional. The location to deploy resources to')
param location string = resourceGroup().location

// ========== //
// Test Setup //
// ========== //

// Add Setup here if required

// ============== //
// Test Execution //
// ============== //

module azureSqlServer '../main.bicep' = {
  name: '${uniqueString(deployment().name, 'AustraliaEast')}-sqlserver'
  params: {
    location: location
    sqlServerName: 'example-dev-sql'
    sqlAdminLogin: 'sqladmin'
    sqlAdminPassword: 'reallystrongpwd'
    enableResourceLock: false
    aadAdminLogin: 'sqladmin-group'
    aadAdminObjectId: 'xxxx-xxx-xxxx-xxx'
  }
}
