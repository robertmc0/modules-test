metadata name = 'Virtual Network Gateway Module'
metadata description = 'This module deploys Microsoft.Network/virtualNetworkGateways'
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

@description('Optional. Enable or disable BGP on the virtual network gateway.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways?tabs=bicep#enablebgp'
  examples: [
    true // Enable BGP
    false // Disable BGP (default)
  ]
})
param enableBgp bool = false

@description('Optional. The additional routes to advertise to VPN clients connecting to the gateway.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways?tabs=bicep#customroutes'
  examples: [
    [
      // Single address prefix example
      '10.20.30.0/24'
    ]
    [
      // Multiple address prefixes example
      '10.20.30.0/24'
      '172.16.0.0/16'
    ]
  ]
})
param customRoutePrefixes array = []

@description('Optional. The address prefixes for VPN clients connecting to the gateway.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways?tabs=bicep#vpnclientaddresspool'
  examples: [
    [
      // Single address prefix example
      '10.10.201.0/24'
    ]
    [
      // Multiple address prefixes example
      '10.10.201.0/24'
      '10.10.202.0/24'
    ]
  ]
})
param vpnClientAddressPoolPrefixes array = []

@description('Optional. The VPN Authentication type(s) to be used.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways?tabs=bicep#vpnauthenticationtypes'
  examples: [
    ['AAD'] // Only AAD authentication
    ['Certificate'] // Only certificate authentication
    ['Radius'] // Only RADIUS authentication
    ['AAD', 'Certificate'] // Both AAD and certificate authentication
  ]
})
@allowed([
  'AAD'
  'Certificate'
  'Radius'
])
param vpnAuthenticationTypes array = []

@description('Optional. The VPN protocol(s) to be used.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways?tabs=bicep#vpnclientprotocol'
  examples: [
    ['IKEv2'] // Only IKEv2
    ['OpenVPN'] // Only OpenVPN
    ['IKEv2', 'OpenVPN'] // Both IKEv2 and OpenVPN
  ]
})
@allowed([
  'IKEv2'
  'SSTP'
  'OpenVPN'
])
param vpnClientProtocols array = []

@description('Optional. The VPN Client root certificates.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways?tabs=bicep#vpnclientrootcertificatepropertiesformat' // Updated tab to bicep
  examples: [
    {
      id: 'rootCert1Id'
      name: 'Root Certificate 1'
      properties: {
        publicCertData: 'base64EncodedCertData1'
      }
    }
  ]
})
param vpnClientRootCertificates array = []

@description('Optional. VPN revoked certificates.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways?tabs=bicep#vpnclientrevokedcertificatepropertiesformat'
  examples: [
    {
      id: 'revokedCert1Id'
      name: 'Revoked Certificate 1'
      properties: {
        thumbprint: 'revokedCert1Thumbprint'
      }
    }
  ]
})
param vpnClientRevokedCertificates array = []

@description('Optional. VPN AAD Auth Details')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways?pivots=deployment-language-bicep#vpnclientconfiguration'
  examples: {
    aadAudience: 'c632b3df-fb67-4d84-bdcf-b95ad541b5c8' // Azure Public - Microsoft-registered
    aadIssuer: 'https://sts.windows.net/{Microsoft ID Entra Tenant ID}/'
    #disable-next-line no-hardcoded-env-urls
    aadTenant: 'https://login.microsoftonline.com/{Microsoft ID Entra Tenant ID}'
  }
})
param vpnAadAuthConfig object = {}

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

var secondaryPublicIpDiagnosticsName = activeActive ? toLower('${secondaryPublicIp.name}-dgs') : 'placeholder'

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

var ipConfigurations = activeActive
  ? [
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
    ]
  : [
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

resource primaryPublicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
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
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId)
      ? null
      : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

resource secondaryPublicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = if (activeActive) {
  name: empty(secondaryPublicIpAddressName) ? 'placeholder' : secondaryPublicIpAddressName
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
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId)
      ? null
      : diagnosticEventHubAuthorizationRuleId
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
    customRoutes: (!empty(customRoutePrefixes))
      ? {
          addressPrefixes: customRoutePrefixes
        }
      : null
    vpnClientConfiguration: (!empty(vpnClientAddressPoolPrefixes) && !empty(vpnAuthenticationTypes) && !empty(vpnClientProtocols))
      ? {
          vpnClientAddressPool: {
            addressPrefixes: vpnClientAddressPoolPrefixes
          }
          vpnAuthenticationTypes: vpnAuthenticationTypes
          vpnClientProtocols: vpnClientProtocols
          vpnClientRevokedCertificates: !empty(vpnClientRevokedCertificates) ? vpnClientRevokedCertificates : null
          vpnClientRootCertificates: !empty(vpnClientRootCertificates) ? vpnClientRootCertificates : null
          aadAudience: !empty(vpnAadAuthConfig) ? vpnAadAuthConfig.aadAudience : null
          aadIssuer: !empty(vpnAadAuthConfig) ? vpnAadAuthConfig.aadIssuer : null
          aadTenant: !empty(vpnAadAuthConfig) ? vpnAadAuthConfig.aadTenant : null
        }
      : null
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: virtualNetworkGateway
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

resource diagnosticsVnetGateway 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: virtualNetworkGateway
  name: vnetGatewayDiagnosticsName
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

@description('The name of the deployed virtual network gateway.')
output name string = virtualNetworkGateway.name

@description('The resource ID of the deployed virtual network gateway.')
output resourceId string = virtualNetworkGateway.id

@description('The name of the deployed virtual network gateway primary public IP.')
output primaryPublicIpName string = primaryPublicIp.name

@description('The IP address of the deployed virtual network gateway primary public IP.')
output primaryPublicIpAddress string = primaryPublicIp.properties.ipAddress

@description('The resource ID of the deployed virtual network gateway primary public IP address.')
output primaryPublicIpId string = virtualNetworkGateway.properties.ipConfigurations[0].properties.publicIPAddress.id

@description('The name of the deployed virtual network gateway secondary public IP.')
output secondaryPublicIpName string = activeActive ? secondaryPublicIp.name : ''

@description('The IP address of the deployed virtual network gateway secondary public IP.')
output secondaryPublicIpAddress string = activeActive ? secondaryPublicIp.properties.ipAddress : ''

@description('The resource ID of the deployed virtual network gateway secondary public IP address.')
output secondaryPublicIpId string = activeActive
  ? virtualNetworkGateway.properties.ipConfigurations[1].properties.publicIPAddress.id
  : ''
