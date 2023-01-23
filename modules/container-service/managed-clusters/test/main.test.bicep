/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('ID of RBAC role definition, see https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for guids')
param roleDefinitionIds array = [
  // 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // reader
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // contributor
  // '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' // owner
]
@description('Optional. Add value to ensure additional uniqueness of resources')
param uniqueId string = ''

/*======================================================================
TEST PREREQUISITES
======================================================================*/
var rbacAssignments = [for roleDefinitionId in roleDefinitionIds: {
  name: guid(managedIdentity.id, resourceGroup().id, roleDefinitionId, uniqueId)
  roleDefinitionId: roleDefinitionId
}]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: '${shortIdentifier}-tst-uai-${uniqueString(deployment().name, 'userAssignedManagedIdentity', location, uniqueId)}'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for rbacAssignment in rbacAssignments: {
  name: rbacAssignment.name
  scope: resourceGroup()
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', rbacAssignment.roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}]

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location, uniqueId)}'
  location: location
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', location, uniqueId)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource diagnosticsEventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsEventHubNamespace', location, uniqueId)}'
  location: location
}

var subnetName = 'aks'

resource vnetMin 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-min-vnet-${uniqueString(deployment().name, 'vnet', location, uniqueId)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/17'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/21'
        }
      }
    ]
  }
}

resource vnetMax 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-max-vnet-${uniqueString(deployment().name, 'vnet', location, uniqueId)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.128.0/17'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.128.0/21'
        }
      }
    ]
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module aksMin '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-aks'
  params: {
    name: '${shortIdentifier}-aks-min-${uniqueString(deployment().name, 'min', location, uniqueId)}'
    location: location
    agentPoolVnetSubnetId: first(filter(vnetMin.properties.subnets, subnet => toLower(subnet.name) == toLower(subnetName))).id
    networkServiceCidr: '10.1.0.0/16'
    networkDnsServiceIp: '10.1.0.10'
  }
}

module aksMax '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-max-aks'
  params: {
    name: '${shortIdentifier}-aks-max-${uniqueString(deployment().name, 'max', location, uniqueId)}'
    location: location
    nodeResourceGroup: '${resourceGroup().name}-nodepool'
    agentPoolCount: 2
    kubernetesVersion: '1.23.12'
    enableAvailabilityZones: true
    enableAutoScaling: true
    agentPoolMinCount: 1
    agentPoolMaxCount: 2
    agentPoolVnetSubnetId: first(filter(vnetMax.properties.subnets, subnet => toLower(subnet.name) == toLower(subnetName))).id
    networkServiceCidr: '10.1.0.0/16'
    networkDnsServiceIp: '10.1.0.10'
    userAssignedIdentities: { '${managedIdentity.id}': {} }
    dnsPrefix: '${shortIdentifier}-aks-max-${uniqueString(deployment().name, 'max', location)}'
    enableAad: true
    enableAzureRbac: true
    enablePrivateCluster: false
    enableAddonAzurePolicy: true
    disableLocalAccounts: true
    upgradeChannel: 'patch'
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.id
    resourceLock: 'CanNotDelete'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubName: diagnosticsEventHubNamespace.name
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
  }
}

@description('The name of the deployed managed cluster.')
output name string = aksMax.outputs.name

@description('The resource ID of the deployed managed cluster.')
output resourceId string = aksMax.outputs.resourceId

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = aksMax.outputs.systemAssignedPrincipalId
