/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Required. The name of the Virtual Machine to create.')
param virtualMachineName string = '${uniqueString(deployment().name, location)}vm'

@description('Optional. The password to leverage for the VM login.')
@secure()
param password string = newGuid()

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource networkWatcher 'Microsoft.Network/networkWatchers@2024-03-01' = {
  name: '${uniqueString(deployment().name, location)}-network-watcher'
  location: location
  properties: {}
}

resource vnet1 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: '${shortIdentifier}-tst-vnet1-${uniqueString(deployment().name, 'virtualNetworks', location)}'
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

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${virtualMachineName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          subnet: {
            id: vnet1.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: virtualMachineName
  location: location
  properties: {
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        deleteOption: 'Delete'
        createOption: 'FromImage'
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    osProfile: {
      adminUsername: '${virtualMachineName}-azureuser'
      adminPassword: password
      computerName: virtualMachineName
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
  }
}

resource NetworkWatcherAgentLinux 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: 'AzureNetworkWatcherExtension'
  parent: virtualMachine
  location: location
  properties: {
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module connectionMonitor '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-connection-monitor'
  dependsOn: [
    NetworkWatcherAgentLinux
  ]
  params: {
    name: '${uniqueString(deployment().name, location)}-connection-monitor'
    location: location
    networkWatcherName: networkWatcher.name
    tags: {test: 'test'}
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    endpoints: [ // source and destinations
      {
        name: 'Bing'
        address: 'www.bing.com'
        type: 'ExternalAddress'
      }
      {
        name: virtualMachineName
        resourceId: virtualMachine.id
        type: 'AzureVM'
      }
    ]
    testConfigurations: [
      {
        name: 'Bing HTTP Test'
        httpConfiguration: {
          method: 'Get'
          port: 80
          preferHTTPS: false
          requestHeaders: []
          validStatusCodeRanges: [
            '200'
          ]
        }
        protocol: 'Http'
        successThreshold: {
          checksFailedPercent: 5
          roundTripTimeMs: 100
        }
        testFrequencySec: 30
      }
    ]
    testGroups: [
      {
        name: 'bing-http-test'
        disable: false
        sources: [virtualMachineName]
        destinations: ['Bing']
        testConfigurations: ['Bing HTTP Test']
      }
    ]
  }
}
