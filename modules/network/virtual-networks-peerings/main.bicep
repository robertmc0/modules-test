@description('The resource name.')
param name string

@description('Name of the source virtual network that is being peered.')
param sourceVirtualNetworkName string

@description('Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network.')
param allowForwardedTraffic bool

@description('If gateway links can be used in remote virtual networking to link to this virtual network.')
param allowGatewayTransit bool

@description('Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space.')
param allowVirtualNetworkAccess bool

@description('Optional. Do not verify the provisioning state of the remote gateway.')
param doNotVerifyRemoteGateways bool = false

@description('Remote virtual network resource id.')
param remoteVirtualNetworkId string

@description('If remote gateways can be used on this virtual network.')
param useRemoteGateways bool

@description('Optional. The peering sync status of the virtual network peering.')
@allowed([
  'FullyInSync'
  'LocalAndRemoteNotInSync'
  'LocalNotInSync'
  'RemoteNotInSync'
])
param peeringSyncLevel string = 'FullyInSync'

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${sourceVirtualNetworkName}/${name}'
  properties: {
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    doNotVerifyRemoteGateways: doNotVerifyRemoteGateways
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkId
    }
    useRemoteGateways: useRemoteGateways
    peeringSyncLevel: peeringSyncLevel
  }
}

@description('The name of the deployed virtual network peering.')
output name string = peering.name

@description('The resource ID of the deployed virtual network peering.')
output resourceId string = peering.id
