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

resource eventHub 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: '${shortIdentifier}-tst-ehub-${uniqueString(deploymentName, 'eventHub', location)}'
  location: location
  properties: {
    minimumTlsVersion: '1.2'
  }
}

resource eventHubRootManageSharedAccessKey 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' existing = {
  name: 'RootManageSharedAccessKey'
  parent: eventHub
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module azureSqlServer '../main.bicep' = {
  name: '${shortIdentifier}-tst-sql-${uniqueString(deploymentName, 'sqlserver', location)}'
  params: {
    location: location
    tags: {
      location: location
    }
    name: '${shortIdentifier}-tst-sql-${uniqueString(deploymentName, 'sqlserver', location)}'
    enableAudit: true
    auditStorageAccountName: diagnosticsStorageAccount.name
    auditLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    auditLogsRetentionInDays: 7
    auditEventHubName: eventHub.name
    auditEventHubAuthorizationRuleId: eventHubRootManageSharedAccessKey.id
    systemAssignedIdentity: true
    administrators: {
      login: 'DSG - All Consultants'
      principalType: 'Group'
      objectId: '7d4930a7-f128-45af-9e70-07f1484c9c4a'
    }
    vulnerabilityAssessmentStorageAccountName: diagnosticsStorageAccount.name
    emailAddresses: [
      'joe.bloggs@hotmail.com'
    ]
  }
}
