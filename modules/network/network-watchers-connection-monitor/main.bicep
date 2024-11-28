metadata name = 'Connection Monitors Module'
metadata description = 'This module deploys Microsoft.Network/networkWatchers connectionMonitors.'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('Optional. Network Watcher name. Default is NetworkWatcher_<location>.')
param networkWatcherName string = 'NetworkWatcher_${resourceGroup().location}'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object?

@description('The geo-location where the resource lives.')
param location string

@description('List of connection monitor endpoints. At least one source and one destination must be specified.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networkwatchers/connectionmonitors?pivots=deployment-language-bicep#connectionmonitorendpoint'
  example: [
    {
      address: 'string'
      coverageLevel: 'AboveAverage | Average | BelowAverage | Default | Full | Low'
      filter: {
        items: [
          {
            address: 'string'
            type: 'string'
          }
        ]
        type: 'string'
      }
      locationDetails: {
        region: 'string'
      }
      name: 'string'
      resourceId: 'string'
      scope: {
        exclude: [
          {
            address: 'string'
          }
        ]
        include: [
          {
            address: 'string'
          }
        ]
      }
      subscriptionId: 'string'
      type: 'AzureArcNetwork | AzureArcVM | AzureSubnet | AzureVM | AzureVMSS | AzureVNet | ExternalAddress | MMAWorkspaceMachine | MMAWorkspaceNetwork'
    }
  ]
})
param endpoints array

@description('List of connection monitor test configurations. At least one test configuration must be specified.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networkwatchers/connectionmonitors?pivots=deployment-language-bicep#connectionmonitortestconfiguration'
  example: [
    {
      httpConfiguration: {
        method: 'string'
        path: 'string'
        port: 'int'
        preferHTTPS: 'true | false'
        requestHeaders: [
          {
            name: 'string'
            value: 'string'
          }
        ]
        validStatusCodeRanges: [
          'string'
        ]
      }
      icmpConfiguration: {
        disableTraceRoute: 'true | false'
      }
      name: 'string'
      preferredIPVersion: 'string'
      protocol: 'string'
      successThreshold: {
        checksFailedPercent: 'int'
        roundTripTimeMs: 'int'
      }
      tcpConfiguration: {
        destinationPortBehavior: 'string'
        disableTraceRoute: 'true | false'
        port: 'int'
      }
      testFrequencySec: 'int'
    }
  ]
})
param testConfigurations array

@description('List of connection monitor test groups. At least one test group must be specified.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networkwatchers/connectionmonitors?pivots=deployment-language-bicep#connectionmonitortestgroup'
  example: [
    {
      destinations: [
        'string'
      ]
      disable: 'true | false'
      name: 'string'
      sources: [
        'string'
      ]
      testConfigurations: [
        'string'
      ]
    }
  ]
})
param testGroups array

@description('Optional. Specify the Log Analytics Workspace Resource ID.')
param logAnalyticsWorkspaceId string?

resource networkWatcher 'Microsoft.Network/networkWatchers@2024-03-01' existing = {
  name: networkWatcherName
}

resource connectionMonitor 'Microsoft.Network/networkWatchers/connectionMonitors@2024-03-01' = {
  name: name
  parent: networkWatcher
  tags: tags
  location: location
  properties: {
    endpoints: endpoints
    testConfigurations: testConfigurations
    testGroups: testGroups
    outputs: !empty(logAnalyticsWorkspaceId)
      ? [
          {
            type: 'Workspace'
            workspaceSettings: {
              workspaceResourceId: logAnalyticsWorkspaceId
            }
          }
        ]
      : null
  }
}

@description('The name of the deployed connection monitor.')
output name string = connectionMonitor.name

@description('The resource ID of the deployed connection monitor.')
output resourceId string = connectionMonitor.id
