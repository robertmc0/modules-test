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
resource virtualWan1 'Microsoft.Network/virtualWans@2022-05-01' = {
  name: '${shortIdentifier}-tst-vwan1-${uniqueString(deployment().name, 'virtualWans', location)}'
  location: location
  properties: {
    type: 'Standard'
  }
}

resource virtualHub1 'Microsoft.Network/virtualHubs@2022-05-01' = {
  name: '${shortIdentifier}-tst-vhub1-${uniqueString(deployment().name, 'virtualHubs', location)}'
  location: location
  properties: {
    addressPrefix: '10.1.0.0/16'
    virtualWan: {
      id: virtualWan1.id
    }
  }
}

resource virtualWan2 'Microsoft.Network/virtualWans@2022-05-01' = {
  name: '${shortIdentifier}-tst-vwan2-${uniqueString(deployment().name, 'virtualWans', location)}'
  location: location
  properties: {
    type: 'Standard'
  }
}

resource virtualHub2 'Microsoft.Network/virtualHubs@2022-05-01' = {
  name: '${shortIdentifier}-tst-vhub2-${uniqueString(deployment().name, 'virtualHubs', location)}'
  location: location
  properties: {
    addressPrefix: '10.2.0.0/16'
    virtualWan: {
      id: virtualWan2.id
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', 'vpnGateway', location)}'
  location: location
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', 'vpnGateway', location)}'
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
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsEventHubNamespace', 'vpnGateway', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module vpnGatewayMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-vpngw'
  params: {
    name: '${shortIdentifier}-tst-vpngw-min-${uniqueString(deployment().name, 'vpnGateway', location)}'
    location: location
    virtualHubResourceId: virtualHub1.id
  }
}

module vpnGateway '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vpngw'
  params: {
    name: '${shortIdentifier}-tst-vpngw-${uniqueString(deployment().name, 'vpnGateway', location)}'
    location: location
    virtualHubResourceId: virtualHub2.id
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: ''
      peerWeight: 5
    }
    enableBgpRouteTranslationForNat: true
    isRoutingPreferenceInternet: true
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
