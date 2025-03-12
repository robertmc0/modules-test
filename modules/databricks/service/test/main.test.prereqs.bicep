@description('The vnet resource name.')
param networkName string

@description('The storage account resource name.')
param storageName string

@description('The log analytics resource name.')
param logAnalyticsName string

@description('The geo-location where the resource lives.')
param location string

@description('The name to use for virtual network public subnet')
param publicSubnetName string = 'dbksPublic'

@description('The name to use for virtual network private subnet')
param privateSubnetName string = 'dbksPrivate'

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {//name needs to be addressed
  name: storageName
  location: location
  kind: 'BlobStorage'
  properties: {
    accessTier: 'Hot'
  }
  sku: {
    name: 'Standard_GRS'
  }
}

resource diagnosticsStorageAccountPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  parent: storage
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          name: 'blob-lifecycle'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterModificationGreaterThan: 30
                }
                delete: {
                  daysAfterModificationGreaterThan: 365
                }
              }
              snapshot: {
                delete: {
                  daysAfterCreationGreaterThan: 365
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: networkName
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
  dependsOn: [
    publicSubnet
  ]
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
output networkName string = virtualNetwork.name

@description('The resource ID of the deployed Virtual Network.')
output networkResourceId string = virtualNetwork.id

@description('The name of the deployed Storage Account.')
output storageName string = storage.name

@description('The resource ID of the deployed Storage Account.')
output storageResourceId string = storage.id

@description('The name of the deployed Log Analytics.')
output logAnalyticsName string = logAnalytics.name

@description('The resource ID of the deployed Log Analytics.')
output logAnalyticsResourceId string = logAnalytics.id
