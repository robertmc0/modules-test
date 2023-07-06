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
resource vnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet1-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet2-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.50.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.50.0.0/24'
        }
      }
    ]
  }
}

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

/*======================================================================
TEST EXECUTION
======================================================================*/
module vnetGatewayMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-vgw'
  params: {
    name: '${shortIdentifier}-tst-vgw-min-${uniqueString(deployment().name, 'vnetGateway', location)}'
    location: location
    gatewayType: 'ExpressRoute'
    sku: 'Standard'
    primaryPublicIpAddressName: '${uniqueString(deployment().name, location)}-min-vgw-pip'
    subnetResourceId: '${vnet1.id}/subnets/GatewaySubnet'
  }
}

module vnetGateway '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vgw'
  params: {
    name: '${shortIdentifier}-tst-vgw-${uniqueString(deployment().name, 'vnetGateway', location)}'
    location: location
    gatewayType: 'Vpn'
    sku: 'VpnGw2AZ'
    vpnType: 'RouteBased'
    activeActive: true
    primaryPublicIpAddressName: '${uniqueString(deployment().name, location)}-vgw-pip01'
    secondaryPublicIpAddressName: '${uniqueString(deployment().name, location)}-vgw-pip02'
    enableBgp: true
    subnetResourceId: '${vnet2.id}/subnets/GatewaySubnet'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
