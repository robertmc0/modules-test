@description('The resource name.')
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

@description('Tier of an Azure Firewall.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param tier string

@description('Optional. The Azure Firewall Resource SKU. Set to AZFW_Hub only if attaching to a Virtual Hub.')
@allowed([
  'AZFW_VNet'
  'AZFW_Hub'
])
param sku string = 'AZFW_VNet'

@description('Optional. Resource ID of the Azure firewall subnet.')
param subnetResourceId string = ''

@description('Optional. Name of the Azure firewall public IP address.')
param publicIpAddressName string = ''

@description('Optional. IP configuration of the Azure Firewall used for management traffic.')
@metadata({
  subnetResourceId: 'Resource ID of the Azure firewall management subnet.'
  publicIpAddressName: 'Name of the Azure firewall management public IP address.'
})
param firewallManagementConfiguration object = {}

@description('Firewall policy name.')
param policyName string

@description('Optional. The operation mode for Threat Intelligence.')
param threatIntelMode string = 'Alert'

@description('Optional. Enable DNS Proxy on Firewalls attached to the Firewall Policy.')
param enableDnsProxy bool = false

@description('Optional. List of Custom DNS Servers. Only required when enableDnsProxy set to true.')
param customDnsServers array = []

@description('Optional. A list of availability zones denoting where the resource should be deployed.')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZones array = []

@description('Optional. Resource ID of the Azure virtual hub.')
param virtualHubResourceId string = ''

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'AllLogs'
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

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${firewall.name}-${resourceLock}-lck')

var publicIpFirewallDiagnosticsName = toLower('${publicIpFirewall.name}-dgs')

var publicIpFirewallMgmtDiagnosticsName = toLower('${publicIpFirewallMgmt.name}-dgs')

var firewallDiagnosticsName = toLower('${firewall.name}-dgs')

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

var firewallProperties = sku == 'AZFW_VNet' ? {
  sku: {
    name: sku
    tier: tier
  }
  ipConfigurations: [
    {
      name: publicIpFirewall.name
      properties: {
        subnet: {
          id: subnetResourceId
        }
        publicIPAddress: {
          id: publicIpFirewall.id
        }
      }
    }
  ]
  managementIpConfiguration: !empty(firewallManagementConfiguration) ? {
    name: publicIpFirewallMgmt.name
    properties: {
      subnet: {
        id: firewallManagementConfiguration.subnetResourceId
      }
      publicIPAddress: {
        id: publicIpFirewallMgmt.id
      }
    }
  } : null
  firewallPolicy: {
    id: firewallPolicy.id
  }
} : {
  sku: {
    name: sku
    tier: tier
  }
  hubIPAddresses: {
    publicIPs: {
      count: 1
    }
  }
  virtualHub: {
    id: virtualHubResourceId
  }
  firewallPolicy: {
    id: firewallPolicy.id
  }
}

resource publicIpFirewall 'Microsoft.Network/publicIPAddresses@2022-01-01' = if (sku == 'AZFW_VNet') {
  name: sku == 'AZFW_VNet' ? publicIpAddressName : 'placeholder1' //placeholder value added as name cannot be null or empty and is evaulated.
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  zones: availabilityZones
}

resource diagnosticsPublicIpFirewall 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((enableDiagnostics) && (sku == 'AZFW_VNet')) {
  scope: publicIpFirewall
  name: publicIpFirewallDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

resource publicIpFirewallMgmt 'Microsoft.Network/publicIPAddresses@2022-01-01' = if (!empty(firewallManagementConfiguration) && (sku == 'AZFW_VNet')) {
  name: !empty(firewallManagementConfiguration) ? firewallManagementConfiguration.publicIpAddressName : 'placeholder2' //placeholder value added as name cannot be null or empty and is evaulated.
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  zones: availabilityZones
}

resource diagnosticsPublicIpFirewallMgmt 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(firewallManagementConfiguration) && (enableDiagnostics) && (sku == 'AZFW_VNet')) {
  scope: publicIpFirewallMgmt
  name: publicIpFirewallMgmtDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: name
  location: location
  tags: tags
  properties: firewallProperties
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01' = {
  name: policyName
  location: location
  tags: tags
  properties: {
    dnsSettings: {
      enableProxy: enableDnsProxy
      servers: customDnsServers
    }
    threatIntelMode: threatIntelMode
    sku: {
      tier: tier
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: firewall
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnosticsFirewall 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: firewall
  name: firewallDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

@description('The name of the deployed Azure firewall.')
output name string = firewall.name

@description('The resource ID of the deployed Azure firewall.')
output resourceId string = firewall.id

@description('Private IP address of the deployed Azure firewall.')
output privateIpAddress string = sku == 'AZFW_VNet' ? firewall.properties.ipConfigurations[0].properties.privateIPAddress : firewall.properties.hubIPAddresses.privateIPAddress
