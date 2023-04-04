/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The environment')
param environment string = 'tst'

@description('Optional. The location to deploy resources to')
param location string = 'australiaeast'

@description('Resource Tags')
param tags object = {}

var uniqueName = uniqueString(deployment().name, location)

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${uniqueName}-umi'
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: '${uniqueName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'private-endpoints'
        properties: {
          addressPrefix: '10.0.0.0/27'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${uniqueName}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Database Level Scale settings by environment
var databaseLevelScalingSettings = {
  dev: {
    autoscaleSettings: {
      maxThroughput: 2000
    }
  }
  tst: {
    autoscaleSettings: {
      maxThroughput: 2000
    }
  }
}

// Container Level Scale settings by environment
var containerLevelScalingSettings = {
  prd: {
    contentdata: {
      autoscaleSettings: {
        maxThroughput: 2000
      }
    }
    memberdata: {
      autoscaleSettings: {
        maxThroughput: 4000
      }
    }
    leases: { // required for change feed
      autoscaleSettings: {
        maxThroughput: 1000
      }
    }
  }
}

var containerConfigurations = [
  {
    id: 'leases' // required for change feed
    options: contains(containerLevelScalingSettings, environment) ? containerLevelScalingSettings[toLower(environment)].leases : {}
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
          path: '/*'
        }
      ]
      excludedPaths: [
        {
          path: '/\'_etag\'/?'
        }
      ]
    }
    uniqueKeyPolicy: {}
  }
  {
    id: 'contentdata'
    options: contains(containerLevelScalingSettings, environment) ? containerLevelScalingSettings[toLower(environment)].contentdata : {}
    partitionKey: {
      paths: [
        '/partitionkey'
      ]
      kind: 'Hash'
    }
    indexingPolicy: {
      indexingMode: 'consistent'
      includedPaths: [
        {
          path: '/partitionkey/?'
        }
      ]
      excludedPaths: [
        {
          path: '/*'
        }
      ]
    }
    uniqueKeyPolicy: {
      uniqueKeys: [
        {
          paths: [
            '/sortkey'
          ]
        }
      ]
    }
  }
  {
    id: 'memberdata'
    options: contains(containerLevelScalingSettings, environment) ? containerLevelScalingSettings[toLower(environment)].memberdata : {}
    partitionKey: {
      paths: [
        '/partitionkey'
      ]
      kind: 'Hash'
    }
    indexingPolicy: {
      indexingMode: 'consistent'
      includedPaths: [
        {
          path: '/partitionkey/?'
        }
        {
          path: '/date/?'
        }
      ]
      excludedPaths: [
        {
          path: '/*'
        }
      ]
    }
    defaultTtl: -1
    uniqueKeyPolicy: {
      uniqueKeys: [
        {
          paths: [
            '/sortkey'
          ]
        }
      ]
    }
  }
]

module cosmosAccountMultiRegionWrite '../main.bicep' = {
  name: '${uniqueName}-cosmos-sql-account-deploy'
  params: {
    location: location
    tags: tags
    containerConfigurations: containerConfigurations
    name: '${uniqueName}-cosmos'
    databaseName: 'db-${toLower(environment)}'
    databaseScalingOptions: contains(databaseLevelScalingSettings, environment) ? databaseLevelScalingSettings[toLower(environment)] : {}
    locations: [
      {
        locationName: 'australiaeast'
        failoverPriority: 0
        isZoneRedundant: false
      }
      {
        locationName: 'eastasia'
        failoverPriority: 1
        isZoneRedundant: false
      }
    ]
    enableMultipleWriteLocations: true
    // if public access is required, use the following properties.
    // allowedIpAddressOrRanges: [
    //   '52.52.52.52'
    // ]
    // publicNetworkAccess: 'Enabled'
    resourcelock: 'CanNotDelete'
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
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticLogCategoryToEnable: [
      'ControlPlaneRequests'
      'DataPlaneRequests'
      'PartitionKeyStatistics'
      'PartitionKeyRUConsumption'
    ]
  }
}

module privateEndpoint '../../../network/private-endpoints/main.bicep' = {
  name: '${uniqueName}-pr-endpoint-deploy'
  params: {
    location: location
    subnetId: vnet.properties.subnets[0].id
    targetResourceId: cosmosAccountMultiRegionWrite.outputs.resourceId
    targetResourceName: cosmosAccountMultiRegionWrite.outputs.name
    targetSubResourceType: 'Sql'
  }
}
