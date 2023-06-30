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

@description('The sku of this virtual network gateway.')
@allowed([
  'Basic'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
  'HighPerformance'
  'Standard'
  'UltraPerformance'
  'VpnGw1'
  'VpnGw1AZ'
  'VpnGw2'
  'VpnGw2AZ'
  'VpnGw3'
  'VpnGw3AZ'
  'VpnGw4'
  'VpnGw4AZ'
  'VpnGw5'
  'VpnGw5AZ'
])
param sku string

@description('The type of this virtual network gateway.')
@allowed([
  'ExpressRoute'
  'LocalGateway'
  'Vpn'
])
param gatewayType string

@description('Optional. The type of this virtual network gateway.')
@allowed([
  'PolicyBased'
  'RouteBased'
])
param vpnType string = 'RouteBased'

@description('Name of the primary virtual network gateway public IP address.')
param primaryPublicIpAddressName string

@description('Optional. A list of availability zones denoting the zone in which the virtual network gateway public IP address should be deployed.')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZones array = []

@description('Resource ID of the virtual network gateway subnet.')
param subnetResourceId string

@description('Optional. Enable active-active mode.')
param activeActive bool = false

@description('Optional. Name of the secondary virtual network gateway public IP address. Only required when activeActive is set to true.')
param secondaryPublicIpAddressName string = ''

@description('Optional. Enable BGP.')
param enableBgp bool = false

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'Audit'
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'Audit'
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

var lockName = toLower('${virtualNetworkGateway.name}-${resourceLock}-lck')

var vnetGatewayDiagnosticsName = toLower('${virtualNetworkGateway.name}-dgs')

var primaryPublicIpDiagnosticsName = toLower('${primaryPublicIp.name}-dgs')

var secondaryPublicIpDiagnosticsName = toLower('${secondaryPublicIp.name}-dgs')

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

var ipConfigurations = activeActive ? [
  {
    name: 'default'
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: subnetResourceId
      }
      publicIPAddress: {
        id: primaryPublicIp.id

      }
    }
  }
  {
    name: 'activeActive'
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: subnetResourceId
      }
      publicIPAddress: {
        id: secondaryPublicIp.id

      }
    }
  }
] : [
  {
    name: 'default'
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: subnetResourceId
      }
      publicIPAddress: {
        id: primaryPublicIp.id

      }
    }
  }
]

resource primaryPublicIp 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: primaryPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  zones: availabilityZones
}

resource diagnosticsPrimaryPublicIp 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: primaryPublicIp
  name: primaryPublicIpDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

resource secondaryPublicIp 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: secondaryPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  zones: availabilityZones
}

resource diagnosticsSecondaryPublicIp 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && activeActive) {
  scope: secondaryPublicIp
  name: secondaryPublicIpDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2022-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipConfigurations: ipConfigurations
    sku: {
      name: sku
      tier: sku
    }
    gatewayType: gatewayType
    vpnType: vpnType
    activeActive: activeActive
    enableBgp: enableBgp
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: virtualNetworkGateway
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnosticsVnetGateway 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: virtualNetworkGateway
  name: vnetGatewayDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

@description('The name of the deployed virtual network gateway.')
output name string = virtualNetworkGateway.name

@description('The resource ID of the deployed virtual network gateway.')
output resourceId string = virtualNetworkGateway.id

@description('The name of the deployed virtual network gateway primary public IP.')
output primaryPublicIpName string = primaryPublicIp.name

@description('The resource ID of the deployed virtual network gateway primary public IP address.')
output primaryPublicIpId string = virtualNetworkGateway.properties.ipConfigurations[0].properties.publicIPAddress.id

@description('The name of the deployed virtual network gateway secondary public IP.')
output secondaryPublicIpName string = secondaryPublicIp.name

@description('The resource ID of the deployed virtual network gateway secondary public IP address.')
output secondaryPublicIpId string = activeActive ? virtualNetworkGateway.properties.ipConfigurations[1].properties.publicIPAddress.id : ''
