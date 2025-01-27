metadata name = 'Managed Clusters Module'
metadata description = 'This module deploys Microsoft.ContainerService managedClusters'
metadata owner = 'Arinco'

import * as Types from './types.bicep'

@description('The resource name.')
@maxLength(63)
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. Sets the uptime SLA tier to enable a financially backed, higher SLA for an AKS cluster.')
@allowed([
  'Free'
  'Paid'
])
param managedClusterSku string = 'Free'

@description('Optional. Node resource group name.')
param nodeResourceGroup string = ''

@description('Optional. Disable static credentials for this cluster. This must only be used on Managed Clusters that are AAD enabled.')
param disableLocalAccounts bool = false

@description('Optional. Custom DNS name prefix. This cannot be updated once the Managed Cluster has been created.')
param dnsPrefix string = ''

@description('Optional. Enable Kubernetes Role-Based Access Control.')
param enableRbac bool = true

@description('Optional. Specify kubernetes version to deploy.')
param kubernetesVersion string = 'latest'

@description('Optional. Create a private Managed Cluster.')
param enablePrivateCluster bool = false

@description('Optional. Specify profile of managed cluster add-on.')
param addonProfiles object = {}

@description('Required. Properties of the primary agent pool.')
param agentPoolProfiles Types.agentPoolType[]

@description('A CIDR notation IP range from which to assign pod IPs when kubenet is used. It must not overlap with any Subnet IP ranges.')
param networkPodCidr string = ''

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param networkServiceCidr string

@description('An IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param networkDnsServiceIp string

@description('Optional. Network plugin used for building the Kubernetes network.')
@allowed([
  'azure'
  'kubenet'
  'none'
])
param networkNetworkPlugin string = 'azure'

@description('Optional. Network plugin mode used for building the Kubernetes network.')
@allowed([
  'overlay'
  ''
])
param networkNetworkPluginMode string = ''

@description('Optional. Network dataplane used in the Kubernetes cluster.')
@allowed([
  'azure'
  'cilium'
])
param networkNetworkDataplane string = 'azure'

@description('Optional. Network dataplane used in the Kubernetes cluster.')
@allowed([
  'loadBalancer'
  'managedNATGateway'
  'userAssignedNATGateway'
  'userDefinedRouting'
])
param networkOutboundType string = 'loadBalancer'

@description('Optional. Enable Istio Service Mesh.')
param istioServiceMeshEnabled bool = false

@description('Optional. Enable Istio Service Mesh Internal Ingress Gateway.')
param istioServiceMeshInternalIngressGatewayEnabled bool = false

@description('Optional. Enable Istio Service Mesh External Ingress Gateway.')
param istioServiceMeshExternalIngressGatewayEnabled bool = false

@description('Optional. Istio Service Mesh Control Plane Revision.')
param istioServiceMeshRevision string = ''

@description('Optional. Enable Azure Active Directory configuration.')
param enableAad bool = false

@description('Optional. Enable Azure RBAC for Kubernetes authorization.')
param enableAzureRbac bool = false

@description('Optional. Enable the Azure Policy profile of managed cluster add-on.')
param enableAddonAzurePolicy bool = false

@description('optional. Enable auto upgrade on the AKS cluster to perform periodic upgrades to the latest Kubernetes version.')
@allowed([
  'none'
  'node-image'
  'patch'
  'stable'
  'rapid'
])
param upgradeChannel string = 'patch'

@description('Optional. The ID(s) to assign to the resource.')
@metadata({
  example: {
    '/subscriptions/<subscription>/resourceGroups/<rgp>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-umi': {}
  }
})
param userAssignedIdentities object = {}

@description('Optional. Enable Defender for Cloud.')
param enableDefenderForCloud bool = false

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

@description('Optional. Enable App Insights Monitoring. Specify App Insights Log Analytics Workspace resourceId.')
param logAnalyticsWorkspaceResourceId string = ''

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'allLogs'
  'audit'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'allLogs'
  'audit'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Event hub name. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubName string = ''

var sku = {
  name: 'Base'
  tier: managedClusterSku
}

var lockName = toLower('${aks.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${aks.name}-dgs')

var diagnosticsLogs = [
  for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
    categoryGroup: categoryGroup
    enabled: true
  }
]

var diagnosticsMetrics = [
  for metric in diagnosticMetricsToEnable: {
    category: metric
    timeGrain: null
    enabled: true
  }
]

var addonAzurePolicy = enableAddonAzurePolicy
  ? {
      azurePolicy: {
        enabled: enableAddonAzurePolicy
      }
    }
  : {}

var addonOmsAgent = !empty(logAnalyticsWorkspaceResourceId)
  ? {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceId: !empty(logAnalyticsWorkspaceResourceId)
            ? logAnalyticsWorkspaceResourceId
            : null
        }
      }
    }
  : {}

var clusterAddons = union(addonAzurePolicy, addonOmsAgent, addonProfiles)

var identityType = !empty(userAssignedIdentities) ? 'UserAssigned' : 'SystemAssigned'

var identity = identityType != 'None'
  ? {
      type: identityType
      userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
    }
  : null

resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: name
  sku: sku
  location: location
  tags: tags
  identity: identity
  properties: {
    nodeResourceGroup: nodeResourceGroup
    disableLocalAccounts: disableLocalAccounts
    dnsPrefix: !empty(dnsPrefix) ? dnsPrefix : name
    enableRBAC: enableRbac
    kubernetesVersion: kubernetesVersion != 'latest' ? kubernetesVersion : null
    agentPoolProfiles: map(agentPoolProfiles, profile => {
      name: profile.name
      count: profile.count ?? 1
      availabilityZones: map(profile.?availabilityZones ?? [1, 2, 3], zone => '${zone}')
      enableAutoScaling: profile.?enableAutoScaling ?? false
      maxCount: profile.?maxCount
      maxPods: profile.?maxPods
      minCount: profile.?minCount
      mode: profile.?mode
      nodeLabels: profile.?nodeLabels
      nodeTaints: profile.?nodeTaints
      osDiskSizeGB: profile.?osDiskSizeGB
      osDiskType: profile.?osDiskType
      osSKU: profile.?osSku
      osType: profile.?osType ?? 'Linux'
      tags: profile.?tags
      type: profile.?type ?? 'VirtualMachineScaleSets'
      vmSize: profile.?vmSize
      #disable-next-line use-resource-id-functions
      vnetSubnetID: profile.?vnetSubnetResourceId
      workloadRuntime: profile.?workloadRuntime
    })

    networkProfile: {
      networkDataplane: networkNetworkDataplane
      networkPlugin: networkNetworkPlugin
      networkPluginMode: networkNetworkPluginMode
      outboundType: networkOutboundType
      podCidr: !empty(networkPodCidr) ? networkPodCidr : null
      serviceCidr: networkServiceCidr
      dnsServiceIP: networkDnsServiceIp
    }
    addonProfiles: clusterAddons
    aadProfile: enableAad
      ? {
          managed: true
          enableAzureRBAC: enableAzureRbac
          tenantID: tenant().tenantId
        }
      : null
    #disable-next-line use-resource-id-functions BCP321 // default to default istio revision if not set
    serviceMeshProfile: istioServiceMeshEnabled
      ? {
          istio: {
            revisions: !empty(istioServiceMeshRevision)
              ? [
                  istioServiceMeshRevision
                ]
              : null
            components: {
              ingressGateways: [
                {
                  enabled: istioServiceMeshInternalIngressGatewayEnabled
                  mode: 'Internal'
                }
                {
                  enabled: istioServiceMeshExternalIngressGatewayEnabled
                  mode: 'External'
                }
              ]
            }
          }
          mode: 'Istio'
        }
      : null
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
    }
    securityProfile: {
      defender: {
        logAnalyticsWorkspaceResourceId: enableDefenderForCloud ? diagnosticLogAnalyticsWorkspaceId : null
        securityMonitoring: {
          enabled: enableDefenderForCloud
        }
      }
    }
    autoUpgradeProfile: upgradeChannel != 'none'
      ? {
          upgradeChannel: upgradeChannel
        }
      : null
    servicePrincipalProfile: identityType == 'SystemAssigned'
      ? {
          clientId: 'msi'
        }
      : null
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: aks
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: aks
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId)
      ? null
      : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

@description('The name of the deployed managed cluster.')
output name string = aks.name

@description('The resource ID of the deployed managed cluster.')
output resourceId string = aks.id

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = aks.identity.?principalId ?? ''

@description('The name of the deployed managed cluster.')
output nodeResourceGroupName string = aks.properties.nodeResourceGroup

@description('The Object ID of the Key Vault Secrets Provider identity.')
output secretProviderPrincipalId string = aks.properties.?addonProfiles.?azureKeyvaultSecretsProvider.?identity.?objectId ?? ''

@description('The Object ID of the AKS kubelet identity.')
output kubeletIdentityObjectId string = aks.properties.?identityProfile.?kubeletidentity.?objectId ?? ''
