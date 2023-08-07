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
@description('Optional. The password for the admin account.')
param adminPassword string = '${toUpper(uniqueString(resourceGroup().id))}-${newGuid()}'

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
        name: 'untrust'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'trust'
        properties: {
          addressPrefix: '10.0.1.0/24'
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
        '172.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'untrust'
        properties: {
          addressPrefix: '172.0.0.0/24'
        }
      }
      {
        name: 'trust'
        properties: {
          addressPrefix: '172.0.1.0/24'
        }
      }
    ]
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', 'fortiGateActiveActive', location)}'
  location: location
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', 'fortiGateActiveActive', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
resource diagnosticsEventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsEventHubNamespace', 'fortiGateActiveActive', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module fortiGateMin '../main.bicep' = {
  name: '${shortIdentifier}-tst-fg-min-${uniqueString(deployment().name, 'fortiGate', location)}'
  params: {
    namePrefix: '${shortIdentifier}minnva'
    location: location
    adminUsername: 'arnforti'
    adminPassword: adminPassword
    externalSubnetId: '${vnet1.id}/subnets/untrust'
    internalSubnetId: '${vnet1.id}/subnets/trust'
    externalLoadBalancerName: '${uniqueString(deployment().name, location)}-externalLoadBalancer-min'
    externalLoadBalancerPublicIpName: '${uniqueString(deployment().name, location)}-loadBalancer-min-pip'
    nsgName: '${uniqueString(deployment().name, location)}-nsg-min-pip'
    internalLoadBalancerName: '${uniqueString(deployment().name, location)}-internalLoadbalancer-min-pip'
  }
}

module fortiGate '../main.bicep' = {
  name: '${shortIdentifier}-tst-fg-${uniqueString(deployment().name, 'fortiGate', location)}'
  params: {
    namePrefix: '${shortIdentifier}nva'
    location: location
    adminUsername: 'arnforti'
    adminPassword: adminPassword
    externalSubnetId: '${vnet2.id}/subnets/untrust'
    internalSubnetId: '${vnet2.id}/subnets/trust'
    externalLoadBalancerName: '${uniqueString(deployment().name, location)}-externalLoadBalancer'
    externalLoadBalancerPublicIpName: '${uniqueString(deployment().name, location)}-loadBalancer-pip'
    nsgName: '${uniqueString(deployment().name, location)}-nsg-pip'
    internalLoadBalancerName: '${uniqueString(deployment().name, location)}-internalLoadbalancer-pip'
    availabilitySetConfiguration: {
      name: '${uniqueString(deployment().name, location)}-availabilitySet-avail'
      platformFaultDomainCount: 2
      platformUpdateDomainCount: 5
    }
    imageVersion: '7.4.0'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
    acceleratedNetworking: true
    size: 'Standard_F2s'
  }
}
