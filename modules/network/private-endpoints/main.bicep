@description('Name of the Resource for which to create the Private Endpoint')
param targetResourceName string

@description('Resource Id of the Resource for which to create the Private Endpoint')
param targetResourceId string

@description('Private Endpoint types')
@allowed([
  'blob'
  'table'
  'queue'
  'file'
  'web'
  'dfs'
  'vault'
])
param type string

@description('Location of the resource.')
param location string

@description('Resource ID of the subnet that will host Private Endpoint.')
param subnetId string

@description('Resource ID of the Private DNS Zone to host Private Endpoint entry.')
param privateDnsZoneId string

@allowed([
  'CanNotDelete'
  'NotSpecified'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: '${targetResourceName}-${type}-pe'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${targetResourceName}-${type}-plink'
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: [
            type
          ]
        }
      }
    ]
  }
}

resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

resource privateEndpoint_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${privateEndpoint.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: privateEndpoint
}

@description('The name of the private endpoint')
output name string = privateEndpoint.name

@description('The resource ID of the private endpoint')
output id string = privateEndpoint.id

// Use a module to extract the network interface details of a private endpoint
// This is required due to issues with using reference() against the private endpoint Nic
module nicInfo 'nicInfo.bicep' = {
  name: 'nicInfo'
  params: {
    nicId: privateEndpoint.properties.networkInterfaces[0].id
  }
}
@description('The private endpoint IP address')
output ipAddress string = nicInfo.outputs.privateIPAddress

@description('The private endpoint IP allocation method')
output ipAllocationMethod string = nicInfo.outputs.privateIPAllocationMethod

