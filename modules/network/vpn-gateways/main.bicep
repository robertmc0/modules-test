metadata name = 'Virtual Network VPN Gateways Module'
metadata description = 'This module deploys Microsoft.Network vpnGateways.'
metadata owner = 'Arinco'

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

@description('Optional. Local network gateway\'s BGP speaker settings.')
@metadata({
  asn: 'The BGP speaker\'s ASN.'
  bgpPeeringAddress: 'The BGP peering address and BGP identifier of this BGP speaker.'
  bgpPeeringAddresses: [
    'BGP peering address with IP configuration ID for virtual network gateway.'
  ]
  peerWeight: 'The weight added to routes learned from this BGP speaker.'
})
param bgpSettings object = {}

@description('Optional. Enable BGP routes translation for NAT on this VpnGateway.')
param enableBgpRouteTranslationForNat bool = false

@description('Optional. Enable Routing Preference property for the Public IP Interface of the VpnGateway.')
param isRoutingPreferenceInternet bool = false

@description('Optional. Virtual Hub resource ID.')
param virtualHubResourceId string = ''

@description('Optional. The scale unit for this vpn gateway.')
param vpnGatewayScaleUnit int = 1

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

var lockName = toLower('${vpnGateway.name}-${resourceLock}-lck')

var vpnGatewayDiagnosticsName = toLower('${vpnGateway.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

resource vpnGateway 'Microsoft.Network/vpnGateways@2022-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    bgpSettings: bgpSettings
    enableBgpRouteTranslationForNat: enableBgpRouteTranslationForNat
    isRoutingPreferenceInternet: isRoutingPreferenceInternet
    virtualHub: {
      id: virtualHubResourceId
    }
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: vpnGateway
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnosticsVnetGateway 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: vpnGateway
  name: vpnGatewayDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

@description('The name of the deployed vpn gateway.')
output name string = vpnGateway.name

@description('The resource ID of the deployed vpn gateway.')
output resourceId string = vpnGateway.id
