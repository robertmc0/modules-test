/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Optional. The resource deployment name.')
param deploymentName string = 'logAnalytics${utcNow()}'

@description('Optional. Resource tags.')
param tags object = {}

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deploymentName, 'diagnosticsStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
  sku: {
    name: 'Standard_LRS'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deploymentName, 'logAnalyticsWorkspace', location)}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: '${shortIdentifier}-tst-sql-${uniqueString(deploymentName, 'sqlserver', location)}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: 'DSG - All Consultants'
      principalType: 'Group'
      sid: '7d4930a7-f128-45af-9e70-07f1484c9c4a'
      tenantId: subscription().tenantId
    }
  }
}

resource elasticPool 'Microsoft.Sql/servers/elasticPools@2022-05-01-preview' = {
  parent: sqlServer
  name: '${shortIdentifier}-ep-${uniqueString(deploymentName, 'elasticpool', location)}'
  location: location
  sku: {
    name: 'StandardPool'
    tier: 'Standard'
    capacity: 50
  }
  properties: {
    maxSizeBytes: 53687091200
    perDatabaseSettings: {
      minCapacity: 0
      maxCapacity: 50
    }
  }
}

// ============== //
// Test Execution //
// ============== //

module sqlDatabase '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-sqldatabase'
  params: {
    location: location
    sqlServerName: sqlServer.name
    databaseName: 'example-dev-db'
    skuType: 'Standard'
    skuCapacity: 10 // DTUs
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    maxDbSize: 10737418240 // 10 GIG
  }
}

module sqlDatabase2 '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-sqldatabase-serverless'
  params: {
    location: location
    sqlServerName: sqlServer.name
    databaseName: 'example2-dev-db'
    skuType: 'vCoreGen5Serverless'
    skuMinCapacity: '0.75'
    skuCapacity: 2 // vCores
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    maxDbSize: 10737418240 // 10 GIG
  }
}
module sqlDatabase3 '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-elasticpool-sqldatabase'
  params: {
    location: location
    sqlServerName: sqlServer.name
    databaseName: 'example3-dev-db'
    skuType: 'ElasticPool'
    skuCapacity: 10 // DTUs
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    maxDbSize: 10737418240 // 10 GIG
    elasticPoolId: elasticPool.id
  }
}
