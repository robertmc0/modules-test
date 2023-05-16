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

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${shortIdentifier}-tst-nsg-${uniqueString(deployment().name, 'networkSecurityGroup', location)}'
  location: location
}

resource routeTable 'Microsoft.Network/routeTables@2022-01-01' = {
  name: '${shortIdentifier}-tst-rt-${uniqueString(deployment().name, 'routeTable', location)}'
  location: location
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${shortIdentifier}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
  location: location
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource vulnStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstmivul${uniqueString(deployment().name, 'vulnStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstmidia${uniqueString(deployment().name, 'diagnosticsStorageAccount', location)}'
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
        name: 'MISubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
          routeTable: {
            id: routeTable.id
          }
          delegations: [
            {
              name: 'Microsoft.Sql/managedInstances'
              properties: {
                serviceName: 'Microsoft.Sql/managedInstances'
              }
            }
          ]
        }
      }
    ]
  }
}

// ============== //
// Test Execution //
// ============== //

module managedInstanceMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-mi'
  params: {
    location: location
    name: '${shortIdentifier}-tst-mi-min-${uniqueString(deployment().name, 'sqlServer', location)}'
    enableVulnerabilityAssessments: false
    administratorLogin: '${shortIdentifier}sqladmin'
    administratorLoginPassword: sqlAdminPassword
    skuName: 'GP_Gen5'
    licenseType: 'BasePrice'
    storageSizeInGB: 32
    vCores: 4
    subnetResourceId: '${vnet.id}/subnets/MISubnet'
  }
}

module managedInstance '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-mi'
  params: {
    location: location
    name: '${shortIdentifier}-tst-mi-${uniqueString(deployment().name, 'managedinstance', location)}'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: 'DSG - All Consultants'
      principalType: 'Group'
      sid: '7d4930a7-f128-45af-9e70-07f1484c9c4a'
      tenantId: 'e27c8f55-2c8d-4851-8059-1199a3dab677'
    }
    skuName: 'GP_Gen5'
    vCores: 4
    storageSizeInGB: 32
    licenseType: 'BasePrice'
    timezoneId: 'AUS Eastern Standard Time'
    systemAssignedIdentity: true
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    primaryUserAssignedIdentityId: userIdentity.id
    emailAddresses: [
      'john.smith@constoso.com'
    ]
    emailAccountAdmins: true
    enableVulnerabilityAssessments: true
    vulnerabilityAssessmentStorageId: vulnStorageAccount.id
    threatDetectionRetentionDays: 30
    subnetResourceId: '${vnet.id}/subnets/MISubnet'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }

}
