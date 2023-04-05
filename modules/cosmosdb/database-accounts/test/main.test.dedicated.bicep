@description('Optional. The location to deploy resources to')
param location string = 'australiaeast'

@description('Resource Tags')
param tags object = {}

var uniqueName = uniqueString(deployment().name, location)

module cosmosAccountDedicatedCompute '../main.bicep' = {
  name: '${uniqueName}-cosmos-account-dedicated-deploy'
  params: {
    tags: tags
    location: location
    name: '${uniqueName}-cosmos-dedicated'
    databaseScalingOptions: {
      throughput: 4000
    }
    containerConfigurations: [
      {
        id: 'orders'
        partitionKey: {
          paths: [
            '/id'
          ]
          kind: 'Hash'
        }
        indexingPolicy: {
          indexingMode: 'consistent'
          automatic: true
          includedPaths: [
            {
              path: '/transactionDate/?'
            }
          ]
          excludedPaths: [
            {
              path: '/*'
            }
          ]
        }
        uniqueKeyPolicy: {}
      }
    ]
    databaseName: 'db'
    locations: [
      {
        locationName: 'australiaeast'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    accountAccess: {
      reader: {
        principalIds: [
          '7d4930a7-f128-45af-9e70-07f1484c9c4a' // DSG - All Consultants
        ]
      }
    }
  }
}
