@description('The vnet resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('The name to use for virtual network public subnet')
param publicSubnetName string = 'dbksPublic'

@description('The name to use for virtual network private subnet')
param privateSubnetName string = 'dbksPrivate'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.0.0.0/16' ]
    }
  }
}

resource publicSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: '${publicSubnetName}-nsg'
  location: location
}

resource publicSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  parent: virtualNetwork
  name: publicSubnetName
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: publicSubnetNSG.id
    }
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
        }
      }
    ]
  }
}

resource privateSubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: '${privateSubnetName}-nsg'
  location: location
}

resource privateSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  parent: virtualNetwork
  name: privateSubnetName
  properties: {
    addressPrefix: '10.0.2.0/24'
    networkSecurityGroup: {
      id: privateSubnetNSG.id
    }
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
        }
      }
    ]
  }
}

@description('The name of the deployed Virtual Network.')
output name string = virtualNetwork.name

@description('The resource ID of the deployed Virtual Network.')
output resourceId string = virtualNetwork.id
