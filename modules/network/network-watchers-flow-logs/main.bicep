@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Network Watcher name.')
param networkWatcherName string

@description('Optional. Number of days to retain flow log records.')
param retention int = 60

@description('Optional. Flag to enable/disable flow logging.')
param enableFlowLogs bool = true

@description('Optional. Flag to enable/disable traffic analytics.')
param enableTrafficAnalytics bool = false

@description('Optional. The interval in minutes which would decide how frequently TA service should do flow analytics.')
@allowed([
  60
  10
])
param trafficAnalyticsInterval int = 60

@description('Resource ID of the network security group to which flow log will be applied.')
param networkSecurityGroupId string

@description('Resource ID of the storage account which is used to store the flow log.')
param storageAccountId string

@description('Optional. Resource ID of the log analytics workspace which is used to store the flow log.')
param logAnalyticsWorkspaceId string = ''

var flowAnalyticsConfiguration = enableTrafficAnalytics ? {
  networkWatcherFlowAnalyticsConfiguration: {
    enabled: true
    trafficAnalyticsInterval: trafficAnalyticsInterval
    workspaceResourceId: logAnalyticsWorkspaceId
  }
} : {
  networkWatcherFlowAnalyticsConfiguration: {
    enabled: false
  }
}

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2021-02-01' = {
  name: '${networkWatcherName}/${name}'
  location: location
  tags: tags
  properties: {
    enabled: enableFlowLogs
    flowAnalyticsConfiguration: flowAnalyticsConfiguration
    format: {
      type: 'JSON'
      version: 2
    }
    retentionPolicy: {
      days: retention
      enabled: true
    }
    storageId: storageAccountId
    targetResourceId: networkSecurityGroupId
  }
}

@description('The name of the deployed flow log.')
output name string = flowLog.name

@description('The resource ID of the deployed flow log.')
output resourceId string = flowLog.id
