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
resource localGateway1 'Microsoft.Network/localNetworkGateways@2022-11-01' = {
  name: '${shortIdentifier}-tst-lclgw1-${uniqueString(deployment().name, 'localNetworkGateways', location)}'
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        '10.100.0.0/24'
      ]
    }
    fqdn: 'contoso.com'
  }
}

resource localGateway2 'Microsoft.Network/localNetworkGateways@2022-11-01' = {
  name: '${shortIdentifier}-tst-lclgw2-${uniqueString(deployment().name, 'localNetworkGateways', location)}'
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        '10.100.0.0/24'
      ]
    }
    fqdn: 'contoso.com'
    bgpSettings: {
      asn: 64512
      bgpPeeringAddress: '10.100.0.250'
    }
  }
}

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
        name: 'GatewaySubnet'
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
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.10.0.0/24'
        }
      }
    ]
  }
}

resource publicIp1 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: '${shortIdentifier}-tst-pip1-${uniqueString(deployment().name, 'publicIPAddresses', location)}'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource publicIp2 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: '${shortIdentifier}-tst-pip2-${uniqueString(deployment().name, 'publicIPAddresses', location)}'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vnetGateway1 'Microsoft.Network/virtualNetworkGateways@2022-11-01' = {
  name: '${shortIdentifier}-tst-vnetgw1-${uniqueString(deployment().name, 'virtualNetworkGateways', location)}'
  location: location
  properties: {
    gatewayType: 'Vpn'
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet1.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: publicIp1.id

          }
        }
      }
    ]
  }
}

resource vnetGateway2 'Microsoft.Network/virtualNetworkGateways@2022-11-01' = {
  name: '${shortIdentifier}-tst-vnetgw2-${uniqueString(deployment().name, 'virtualNetworkGateways', location)}'
  location: location
  properties: {
    gatewayType: 'Vpn'
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet2.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: publicIp2.id

          }
        }
      }
    ]
    enableBgp: true
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '10.0.0.254'
    }
  }
}

resource egressNatRule 'Microsoft.Network/virtualNetworkGateways/natRules@2022-11-01' = {
  name: '${shortIdentifier}-tst-egressnat-${uniqueString(deployment().name, 'natRules', location)}'
  parent: vnetGateway2
  properties: {
    type: 'Dynamic'
    mode: 'EgressSnat'
    internalMappings: [
      {
        addressSpace: '10.20.0.0/24'
      }
    ]
    externalMappings: [
      {
        addressSpace: '10.40.0.0/26'
      }
    ]
  }
}

resource ingressNatRule 'Microsoft.Network/virtualNetworkGateways/natRules@2022-11-01' = {
  name: '${shortIdentifier}-tst-ingressnat-${uniqueString(deployment().name, 'natRules', location)}'
  parent: vnetGateway2
  properties: {
    type: 'Dynamic'
    mode: 'IngressSnat'
    internalMappings: [
      {
        addressSpace: '10.30.0.0/24'
      }
    ]
    externalMappings: [
      {
        addressSpace: '10.60.0.0/26'
      }
    ]
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module connectionMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-connection'
  params: {
    name: '${uniqueString(deployment().name, location)}minconn'
    location: location
    connectionProtocol: 'IKEv2'
    connectionType: 'IPsec'
    localNetworkGatewayId: localGateway1.id
    sharedKey: 'secretSharedPSK'
    virtualNetworkGatewayId: vnetGateway1.id
  }
}

module connection '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-connection'
  params: {
    name: '${uniqueString(deployment().name, location)}conn'
    location: location
    connectionProtocol: 'IKEv2'
    connectionType: 'IPsec'
    localNetworkGatewayId: localGateway2.id
    sharedKey: 'secretSharedPSK'
    virtualNetworkGatewayId: vnetGateway2.id
    ipsecPolicies: [
      {
        saLifeTimeSeconds: 28800
        saDataSizeKilobytes: 102400000
        ipsecEncryption: 'AES256'
        ipsecIntegrity: 'SHA256'
        ikeEncryption: 'AES256'
        ikeIntegrity: 'SHA256'
        dhGroup: 'ECP384'
        pfsGroup: 'PFS2048'
      }
    ]
    connectionMode: 'InitiatorOnly'
    dpdTimeoutSeconds: 30
    enableBgp: true
    usePolicyBasedTrafficSelectors: false
    egressNatRules: [
      {
        id: egressNatRule.id
      }
    ]
    ingressNatRules: [
      {
        id: ingressNatRule.id
      }
    ]
  }
}
