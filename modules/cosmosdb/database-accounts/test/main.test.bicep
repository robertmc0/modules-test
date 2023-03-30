@description('Optional. The location to deploy resources to')
param location string = 'australiaeast'

@description('Resource Tags')
param tags object = {}

var uniqueName = uniqueString(deployment().name, location)

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${uniqueName}-umi'
  location: location
}
module cosmosAccountMin '../main.bicep' = {
  name: '${uniqueName}-cosmos-account-min-deploy'
  params: {
    tags: tags
    location: location
    name: '${uniqueName}-cosmos-min'
    containerConfigurations: [
      {
        id: 'orders'
        partitionKey: {
          paths: [
            '/id'
          ]
        }
      }
    ]
    databaseName: 'db'
    locations: [
      {
        locationName: 'australiaeast'
      }
    ]
    accountAccess: {
      reader: {
        principalIds: [
          '7d4930a7-f128-45af-9e70-07f1484c9c4a' // DSG - All Consultants
        ]
      }
      contributor: {
        principalIds: [
          userAssignedIdentity.properties.principalId
        ]
      }
    }
  }
}
