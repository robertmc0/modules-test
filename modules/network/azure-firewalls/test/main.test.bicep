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
        name: 'AzureFirewallSubnet'
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
        '10.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.20.0.0/24'
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: '10.20.1.0/24'
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
module firewallMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-firewall'
  params: {
    name: '${shortIdentifier}-tst-min-fwl-${uniqueString(deployment().name, 'azureFirewall', location)}'
    location: location
    tier: 'Standard'
    subnetResourceId: '${vnet1.id}/subnets/AzureFirewallSubnet'
    publicIpAddressName: '${uniqueString(deployment().name, location)}-min-firewall-pip'
    policyName: '${uniqueString(deployment().name, location)}-min-firewall-tst-afwp'
  }
}

module firewall '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-firewall'
  params: {
    name: '${shortIdentifier}-tst-fwl-${uniqueString(deployment().name, 'azureFirewall', location)}'
    location: location
    tier: 'Standard'
    subnetResourceId: '${vnet2.id}/subnets/AzureFirewallSubnet'
    publicIpAddressName: '${uniqueString(deployment().name, location)}-firewall-pip'
    policyName: '${uniqueString(deployment().name, location)}-firewall-tst-afwp'
    mgmtPublicIpAddressName: '${uniqueString(deployment().name, location)}-firewallmgmt-pip'
    mgmtSubnetResourceId: '${vnet2.id}/subnets/AzureFirewallManagementSubnet'
    enableDnsProxy: true
    customDnsServers: [
      '10.1.2.3'
      '10.3.4.5'
    ]
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
