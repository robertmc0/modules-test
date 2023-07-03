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

@description('Gateway connection type.')
@allowed([
  'ExpressRoute'
  'IPsec'
  'VPNClient'
  'Vnet2Vnet'
])
param connectionType string

@description('The resource ID of the virtual network gateway.')
param virtualNetworkGatewayId string

@description('Optional. Enable BGP for this connection.')
param enableBgp bool = false

@description('Connection protocol used for this connection.')
@allowed([
  'IKEv1'
  'IKEv2'
])
param connectionProtocol string

@description('The IPSec shared key (PSK).')
param sharedKey string

@description('Optional. IPsec policies to be considered by this connection.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/connections?pivots=deployment-language-bicep#ipsecpolicy'
  example: {
    saLifeTimeSeconds: 28800
    saDataSizeKilobytes: 102400000
    ipsecEncryption: 'AES256'
    ipsecIntegrity: 'SHA256'
    ikeEncryption: 'AES256'
    ikeIntegrity: 'SHA256'
    dhGroup: 'ECP384'
    pfsGroup: 'PFS2048'
  }
})
param ipsecPolicies array = []

@description('Optional. Use policy-based traffic selectors for this connection.')
param usePolicyBasedTrafficSelectors bool = false

@description('Optional. The dead peer detection timeout of this connection in seconds.')
param dpdTimeoutSeconds int = 45

@description('Optional. The connection mode used for this connection.')
@allowed([
  'Default'
  'ResponderOnly'
  'InitiatorOnly'
])
param connectionMode string = 'Default'

@description('The resource ID of the local network gateway.')
param localNetworkGatewayId string

@description('Optional. Ingress NAT rules for this connection.')
@metadata({
  id: 'Resource ID of the NAT rule.'
})
param ingressNatRules array = []

@description('Optional. Egress NAT rules for this connection.')
@metadata({
  id: 'Resource ID of the NAT rule.'
})
param egressNatRules array = []

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${connection.name}-${resourceLock}-lck')

resource connection 'Microsoft.Network/connections@2022-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    connectionType: connectionType
    virtualNetworkGateway1: {
      id: virtualNetworkGatewayId
      properties: {}
    }
    enableBgp: enableBgp
    connectionProtocol: connectionProtocol
    sharedKey: sharedKey
    ipsecPolicies: ipsecPolicies
    usePolicyBasedTrafficSelectors: usePolicyBasedTrafficSelectors
    dpdTimeoutSeconds: dpdTimeoutSeconds
    connectionMode: connectionMode
    ingressNatRules: ingressNatRules
    egressNatRules: egressNatRules
    localNetworkGateway2: {
      id: localNetworkGatewayId
      properties: {}
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: connection
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed connection.')
output name string = connection.name

@description('The resource ID of the deployed connection.')
output resourceId string = connection.id
