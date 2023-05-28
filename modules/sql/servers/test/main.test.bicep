/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@secure()
@description('SQL administrator login password')
param sqlAdminPassword string = '${toUpper(uniqueString(resourceGroup().id))}-${newGuid()}'

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${shortIdentifier}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
  location: location
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstaudit${uniqueString(deployment().name, 'auditStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource vulnStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstvuln${uniqueString(deployment().name, 'vulnStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource diagnosticsEventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsEventHubNamespace', location)}'
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
            }
          ]
        }
      }
    ]
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module sqlServerMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-sql'
  params: {
    location: location
    name: '${shortIdentifier}-tst-sql-min-${uniqueString(deployment().name, 'sqlServer', location)}'
    enableAudit: false
    enableVulnerabilityAssessments: false
    administratorLogin: '${shortIdentifier}sqladmin'
    administratorLoginPassword: sqlAdminPassword
    vulnerabilityAssessmentStorageId: vulnStorageAccount.id
    auditStorageAccountId: auditStorageAccount.id
  }
}

module sqlServer '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-sql'
  params: {
    location: location
    name: '${shortIdentifier}-tst-sql-${uniqueString(deployment().name, 'sqlServer', location)}'
    administrators: {
      login: 'DSG - All Consultants'
      principalType: 'Group'
      objectId: '7d4930a7-f128-45af-9e70-07f1484c9c4a'
    }
    enableAudit: true
    auditStorageAccountId: auditStorageAccount.id
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    primaryUserAssignedIdentityId: userIdentity.id
    emailAddresses: [
      'john.smith@constoso.com'
    ]
    emailAccountAdmins: true
    connectionType: 'Redirect'
    enableVulnerabilityAssessments: true
    vulnerabilityAssessmentStorageId: vulnStorageAccount.id
    threatDetectionRetentionDays: 30
    subnetResourceId: '${vnet.id}/subnets/default'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
