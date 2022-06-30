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

// resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
//   scope: resourceGroup('saw-storage-rg')
//   name: 'sawdemodata'
// }

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deploymentName,'logAnalyticsWorkspace',location)}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
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
    //auditStorageResourceGroup: 'another-storage-rg'
    //auditStorageSubscriptionId: subscription().subscriptionId
    auditLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    auditLogsRetentionInDays: 7
    systemAssignedIdentity: true
    administrators: {
      login: 'DSG - All Consultants'
      principalType: 'Group'
      objectId: '7d4930a7-f128-45af-9e70-07f1484c9c4a'
    }
    vulnerabilityAssessmentStorageAccountName: diagnosticsStorageAccount.name
    //vulnerabilityAssessmentStorageResourceGroup: 'another-storage-rg'
    //vulnerabilityAssessmentStorageSubscriptionId: subscription().subscriptionId
    emailAddresses: [
      'joe.bloggs@hotmail.com'
    ]
  }
}
