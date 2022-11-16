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
param managedClusterSKU string = 'Free'

@description('Optional. Node resource group name.')
param nodeResourceGroup string = ''

@description('Optional. Disable static credentials for this cluster. This must only be used on Managed Clusters that are AAD enabled')
param disableLocalAccounts bool = false

@description('Optional. Custom DNS name prefix. This cannot be updated once the Managed Cluster has been created.')
param dnsPrefix string = ''

@description('Optional. Enable Kubernetes Role-Based Access Control.')
param enableRBAC bool = true

@description('Optional. Specify kubernetes version to deploy.')
param kubernetesVersion string = 'latest'

@description('Optional. Create a private Managed Cluster')
param enablePrivateCluster bool = false

@description('Optional. Specify profile of managed cluster add-on.')
param addonProfiles object = {}

@description('Optional. Agent Pool name')
param agentPoolName string = 'agentpool'

@description('Optional. OS Disk Size in GB to be used to specify the disk size for every machine in the master/agent pool.')
param agentPoolOsDiskSizeGB int = 128

@description('Existing VNET resourceid dedicated for use with a Managed Cluster')
param agentPoolVnetSubnetId string

@description('Optional. The maximum number of nodes for auto-scaling')
param agentPoolMaxCount int = 1

@description('Optional. The maximum number of pods that can run on a node.')
param agentPoolMaxPods int = 30

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param networkServiceCidr string

@description('An IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param networkDnsServiceIp string

@description('Optional. A CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range. Default 172.17.0.1')
param networkDockerBridgeCidr string = '172.17.0.1/16'

@description('Optional. A cluster must have at least one "System" Agent Pool at all times. For additional information on agent pool restrictions and best practices')
@allowed([
  'User'
  'System'
])
param agentPoolMode string = 'System'

@description('Optional. The type of Agent Pool.')
@allowed([
  'AvailabilitySet'
  'VirtualMachineScaleSets'
])
param agentPoolType string = 'VirtualMachineScaleSets'

@description('Optional. Enable Availability zones for the agentpool nodes. This can only be specified if the AgentPoolType property is VirtualMachineScaleSets.')
param enableAvailabilityZones bool = false

@description('Optional. Number of agents (VMs) to host docker containers. Allowed values must be in the range of 0 to 1000 (inclusive) for user pools and in the range of 1 to 1000 (inclusive) for system pools.')
@minValue(1)
param agentPoolCount int = 1

@description('Optional. Enables the Managed Cluster auto-scaler')
param enableAutoScaling bool = false

@description('Optional. Virtual Machine size of the nodes in the Managed Cluster.')
param agentPoolVMSize string = 'Standard_B2s'

@description('Optional. Network plugin used for building the Kubernetes network.')
@allowed([
  'azure'
  'kubenet'
  'none'
])
param networkNetworkPlugin string = 'azure'

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

@description('Optional. Enables system assigned managed identity on the resource. Enable if not using User Assigned Managed Identity.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
@metadata({
  example: {
    '/subscriptions/<subscription>/resourceGroups/<rgp>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-umi': {}
  }
})
param userAssignedIdentities object = {}

@description('Optional. Enable Azure Active Directory configuration.')
param enableAad bool = false

@description('Optional. Enable Azure RBAC for Kubernetes authorization.')
param enableAzureRBAC bool = false

@description('Optional. Enable the Azure Policy profile of managed cluster add-on.')
param enableAddonAzurePolicy bool = false

@description('Optional. Enable Defender for Cloud')
param enableDefenderForCloud bool = false

@description('Optional. Enable App Insights Monitoring. Specify App Insights Log Analytics Workspace resourceId.')
param logAnalyticsWorkspaceResourceID string = ''

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

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Event hub name. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubName string = ''

var sku = {
  name: 'Basic'
  tier: managedClusterSKU
}

var lockName = toLower('${aks.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${aks.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var addonAzurePolicy = enableAddonAzurePolicy ? {
  azurePolicy: {
    enabled: enableAddonAzurePolicy
  }
} : {}

var addonOmsAgent = !empty(logAnalyticsWorkspaceResourceID) ? {
  omsagent: {
    enabled: true
    config: {
      logAnalyticsWorkspaceResourceID: !empty(logAnalyticsWorkspaceResourceID) ? logAnalyticsWorkspaceResourceID : null
    }
  }
} : {}

var clusterAddons = union(addonAzurePolicy, addonOmsAgent, addonProfiles)

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var availabilityZones = [
  '1'
  '2'
  '3'
]

resource aks 'Microsoft.ContainerService/managedClusters@2022-09-01' = {
  name: name
  sku: sku
  location: location
  tags: tags
  identity: identity
  properties: {
    nodeResourceGroup: nodeResourceGroup
    disableLocalAccounts: disableLocalAccounts
    dnsPrefix: !empty(dnsPrefix) ? dnsPrefix : name
    enableRBAC: enableRBAC
    kubernetesVersion: kubernetesVersion != 'latest' ? kubernetesVersion : null
    agentPoolProfiles: [ {
        name: agentPoolName
        availabilityZones: enableAvailabilityZones ? availabilityZones : null
        count: agentPoolCount
        enableAutoScaling: enableAutoScaling
        vmSize: agentPoolVMSize
        osDiskSizeGB: agentPoolOsDiskSizeGB
        vnetSubnetID: agentPoolVnetSubnetId
        minCount: enableAutoScaling && agentPoolCount > 1 ? agentPoolCount : null
        maxCount: enableAutoScaling && agentPoolCount > 1 ? agentPoolMaxCount : null
        maxPods: agentPoolMaxPods
        mode: agentPoolMode
        type: agentPoolType
      } ]
    networkProfile: {
      networkPlugin: networkNetworkPlugin
      serviceCidr: networkServiceCidr
      dnsServiceIP: networkDnsServiceIp
      dockerBridgeCidr: networkDockerBridgeCidr
    }
    addonProfiles: clusterAddons
    aadProfile: enableAad ? {
      managed: true
      enableAzureRBAC: enableAzureRBAC
      tenantID: tenant().tenantId
    } : null
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
    }
    securityProfile: enableDefenderForCloud ? {
      defender: {
        logAnalyticsWorkspaceResourceId: diagnosticLogAnalyticsWorkspaceId
        securityMonitoring: {
          enabled: enableDefenderForCloud
        }
      }
    } : null
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: aks
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: aks
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
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
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(aks.identity, 'principalId') ? aks.identity.principalId : ''
