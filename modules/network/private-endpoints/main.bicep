@description('Name of the target resource for which to create the Private Endpoint.')
param targetResourceName string

@description('Resource Id of the target resource for which to create the Private Endpoint.')
param targetResourceId string

@description('The type of sub-resource for the target resource that the private endpoint will be able to access.')
@metadata({
  examples: [
    'blob'
    'table'
    'queue'
    'file'
    'web'
    'dfs'
    'vault'
    'sqlServer'
    'searchService'
    'gateway'
    'namespace'
    'managedInstance'
    'databricks_ui_api'
  ]
})
param targetSubResourceType string

@description('Location of the resource.')
param location string

@description('Resource ID of the subnet that will host the Private Endpoint.')
param subnetId string

@description('Optional. Resource ID of the Private DNS Zone to host the Private Endpoint.')
param privateDnsZoneId string = ''

@description('Optional. Private endpoint DNS Group Name. Defaults to default.')
param privateDNSZoneGroupName string = 'default'

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourcelock string = 'NotSpecified'

var lockName = toLower('${privateEndpoint.name}-${resourcelock}-lck')

var privateEndpointName = toLower('${targetResourceName}-${toLower(targetSubResourceType)}-pe')

var privateLinkServiceName = toLower('${targetResourceName}-${toLower(targetSubResourceType)}-plink')

var networkInterfaceName = '${privateEndpointName}-nic'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: networkInterfaceName
    privateLinkServiceConnections: [
      {
        name: privateLinkServiceName
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: [
            targetSubResourceType
          ]
        }
      }
    ]
  }

  resource privateDNSZoneGroup 'privateDnsZoneGroups@2022-01-01' = if (!empty(privateDnsZoneId)) {
    name: privateDNSZoneGroupName
    properties: {
      privateDnsZoneConfigs: [
        {
          name: privateDNSZoneGroupName
          properties: {
            privateDnsZoneId: privateDnsZoneId
          }
        }
      ]
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: privateEndpoint
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}
@description('The name of the private endpoint.')
output name string = privateEndpoint.name

@description('The resource ID of the private endpoint.')
output resourceId string = privateEndpoint.id

// Use a module to extract the network interface details of a private endpoint
// This is required due to issues with using reference() against the private endpoint Nic
module nicInfo 'nicInfo.bicep' = {
  name: 'nicInfo-pe-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    nicId: privateEndpoint.properties.networkInterfaces[0].id
  }
}
@description('The private endpoint IP address.')
output ipAddress string = nicInfo.outputs.privateIPAddress

@description('The private endpoint IP allocation method.')
output ipAllocationMethod string = nicInfo.outputs.privateIPAllocationMethod
