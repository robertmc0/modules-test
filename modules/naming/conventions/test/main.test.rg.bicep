targetScope = 'subscription'

@description('Resource group location.')
param location string

@description('Resource group name.')
param name string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: name
  location: location
}
