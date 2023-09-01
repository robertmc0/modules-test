/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${shortIdentifier}-tst-nsg-${uniqueString(deployment().name, 'networkSecurityGroup', location)}'
  location: location
}

resource natGateway 'Microsoft.Network/natGateways@2022-01-01' = {
  name: '${shortIdentifier}-tst-nat-${uniqueString(deployment().name, 'natGateway', location)}'
  location: location
  sku: {
    name: 'Standard'
  }
}

resource routeTable 'Microsoft.Network/routeTables@2022-01-01' = {
  name: '${shortIdentifier}-tst-rt-${uniqueString(deployment().name, 'routeTable', location)}'
  location: location
}

resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2021-02-01' = {
  name: '${shortIdentifier}-tst-ddos-${uniqueString(deployment().name, 'ddosProtectionPlan', location)}'
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

resource diagnosticsStorageAccountPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  parent: diagnosticsStorageAccount
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          name: 'blob-lifecycle'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterModificationGreaterThan: 30
                }
                delete: {
                  daysAfterModificationGreaterThan: 365
                }
              }
              snapshot: {
                delete: {
                  daysAfterCreationGreaterThan: 365
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
}

resource diagnosticsEventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsEventHubNamespace', location)}'
  location: location
}
/*======================================================================
TEST EXECUTION
======================================================================*/
module virtualNetworkMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-virtual-network'
  params: {
    name: '${uniqueString(deployment().name, location)}minvnet'
    location: location
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: 'subnet1'
        addressPrefix: '10.0.0.0/24'
      }
    ]
  }
}

module virtualNetwork '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-virtual-network'
  params: {
    name: '${uniqueString(deployment().name, location)}vnet'
    location: location
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    dnsServers: [
      '10.0.0.1'
      '10.0.0.4'
      '172.60.0.4'
    ]
    ddosProtectionPlanId: ddosProtectionPlan.id
    subnets: [
      {
        name: 'subnet1'
        addressPrefix: '10.0.0.0/24'
      }
      {
        name: 'subnet2'
        addressPrefix: '10.0.1.0/24'
        networkSecurityGroupId: nsg.id
        routeTableId: routeTable.id
        natGatewayId: natGateway.id
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Disabled'
        delegation: 'Microsoft.Web/serverFarms'
        serviceEndpoints: [
          {
            service: 'Microsoft.Web'
          }
        ]
      }
    ]
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
