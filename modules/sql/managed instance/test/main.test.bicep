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

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${shortIdentifier}-tst-nsg-${uniqueString(deployment().name, 'networkSecurityGroup', location)}'
  location: location
}

resource routeTable 'Microsoft.Network/routeTables@2022-01-01' = {
  name: '${shortIdentifier}-tst-rt-${uniqueString(deployment().name, 'routeTable', location)}'
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

// ============== //
// Test Execution //
// ============== //

module managedInstance '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-mi'
  params: {
    location: location
    tags: tags
    name: '${shortIdentifier}-tst-mi-${uniqueString(deploymentName, 'managedinstance', location)}'
    skuName: 'GP_Gen5'
    vCores: 4
    storageSizeInGB: 32
    systemAssignedIdentity: true
    subnetId: '${vnet.id}/subnets/MISubnet'
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    enableDiagnostics: true
    licenseType: 'BasePrice'
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    timezoneId: 'AUS Eastern Standard Time'
    administrators: {
      administratorType: 'activeDirectory'
      login: 'LandingZone-App1-NonProd-Contributor'
      sid: '917c73fd-27c0-4338-aee9-a297c01fa2e8'
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
      principalType: 'Group'
    }
    dbNames: [
      'database1'
      'database2'
    ]
    /*     administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: 'DSG - All Consultants'
      principalType: 'Group'
      sid: '7d4930a7-f128-45af-9e70-07f1484c9c4a'
      tenantId: subscription().tenantId
    } */
  }

}
