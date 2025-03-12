/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('The location which test resources will be deployed to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Required. The administrator login password for the MySQL Server.')
@secure()
param administratorLoginPassword string = uniqueString(newGuid())

var tenantId = subscription().tenantId

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
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

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${shortIdentifier}-tst-uai-${uniqueString(deployment().name, 'userAssiignedIdentity', location)}'
  location: location
}
/*======================================================================
TEST EXECUTION
======================================================================*/

module mysqlFlexibleServerMin '../main.bicep' = {
  name: '${shortIdentifier}-tst-mysql-${uniqueString(deployment().name, 'min-mysqlFlexibleServer', location)}'
  params: {
    name: '${shortIdentifier}-tst-mysql-${uniqueString(deployment().name, 'min-mysqlFlexibleServer', location)}'
    location: location
    skuName: 'Standard_D4ds_v4'
    tier: 'GeneralPurpose'
    version: '8.0.21'
    administratorLogin: 'mysqladmin'
    administratorLoginPassword: administratorLoginPassword
  }
}

module mysqlFlexibleServer '../main.bicep' = {
  name: '${shortIdentifier}-tst-mysql-${uniqueString(deployment().name, 'mysqltstFlexibleServer', location)}'
  params: {
    name: '${shortIdentifier}-tst-mysql-${uniqueString(deployment().name, 'mysqltstFlexibleServer', location)}'
    location: location
    skuName: 'Standard_D4ds_v4'
    tier: 'GeneralPurpose'
    version: '8.0.21'
    administratorLogin: 'mysqladmin'
    administratorLoginPassword: administratorLoginPassword
    databases: [
      {
        name: 'testdb01'
        charset: 'utf8'
        collation: 'utf8_general_ci'
      }
      {
        name: 'testdb02'
        charset: 'utf8'
        collation: 'utf8_general_ci'
      }
    ]
    identityType: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}' : {}
    }
    enableDiagnostics: true
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    firewallRules: [
      {
        name: 'AllowAllWindowsAzureIps'
        startIpAddress: '0.0.0.0'
        endIpAddress: '0.0.0.0'
      }
    ]
    administrator: {
      identityResourceId: userAssignedIdentity.id
      sid: userAssignedIdentity.properties.principalId
      login: userAssignedIdentity.name
      tenantId: tenantId
    }
  }
}
