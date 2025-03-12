/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

param kind string = 'Windows'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {
  environment: 'test'
}

@description('VM Administrator Password')
@secure()
param adminPassword string

@description('VM Adminstrator Username')
param adminUsername string
/*======================================================================
TEST PREREQUISITES
======================================================================*/

// Consider the a scenario where VMs are in different subscriptions and resource groups. Use Id instead of name. Refer to test execution associationMultipleVms for example
var vmNameList = [
  vm1.id
  vm2.id
  vm3.id
]

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${uniqueString(deployment().name, location)}-law'
  location: location
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr'
  location: location
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'performanceCounters'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 15
          counterSpecifiers: [
            '\\Processor(_Total)\\% Processor Time'
            '\\Memory\\Committed Bytes'
            '\\LogicalDisk(_Total)\\Free Megabytes'
            '\\PhysicalDisk(_Total)\\Avg. Disk Queue Length'
          ]
        }
      ]
      windowsEventLogs: [
        {
          name: 'DS_WindowsEventLogs'
          streams: [
            'Microsoft-Event'
          ]
        }
      ]
    }
    dataFlows: [
      {
        destinations: [
          'myloganalyticsworkspace'
        ]
        streams: [
          'Microsoft-Event'
          'Microsoft-InsightsMetrics'
          'Microsoft-Perf'
          'Microsoft-Syslog'
        ]
      }
    ]
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspace.id
          name: 'myloganalyticsworkspace'
        }
      ]
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-07-01' = [
  for i in range(0, 3): {
    name: 'nic${format('{0:D2}', i + 1)}tst'
    location: location
    tags: tags
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            subnet: {
              id: '${vnet.id}/subnets/default'
            }
            privateIPAllocationMethod: 'Dynamic'
          }
        }
      ]
    }
  }
]

resource vm1 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'vm1'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'os-disk-01'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[0].id
        }
      ]
    }
    osProfile: {
      computerName: 'vm1'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'vm2'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'os-disk-02'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[1].id
        }
      ]
    }
    osProfile: {
      computerName: 'vm2'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}

resource vm3 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'vm3'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'os-disk-03'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[2].id
        }
      ]
    }
    osProfile: {
      computerName: 'vm3'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module associationSingleVm '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-assc'
  params: {
    location: location
    kind: kind
    dataCollectionRuleId: dcr.id
    virtualMachineName: vm2.name
  }
}

module associationMultipleVms '../main.bicep' = [
  for i in range(0, length(vmNameList)): {
    name: 'dcr-association-${i}-${uniqueString(deployment().name, location)}'
    scope: resourceGroup(split(vmNameList[i], '/')[2], split(vmNameList[i], '/')[4])
    params: {
      location: location
      kind: kind
      dataCollectionRuleId: dcr.id
      virtualMachineName: split(vmNameList[i], '/')[8]
    }
  }
]
