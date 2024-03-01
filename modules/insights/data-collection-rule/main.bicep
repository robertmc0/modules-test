metadata name = 'Insights data collection rule Module.'
metadata description = 'This module deploys Microsoft.Insights dataCollectionRules.'
metadata owner = 'Arinco'

@description('Required. Name of the Data collection rule.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Required. Resource ID of the Log Analytics Workspace that has the VM Insights data.')
param workspaceId string

@description('Optional. A random generated set of strings for resource naming')
param shortenedUniqueString string = substring(uniqueString(utcNow()), 0, 4)

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('The operating system kind in which DCR will be configured to.')
@allowed([
  'Windows'
  'Linux'
  ''
])
param kind string = ''

// Data collection settings

@description('Optional. The resource ID of the data collection endpoint that this rule can be used with.')
param dataCollectionEndpointId string = ''

@description('Optional. A list of specifier names for VM Performance telemetry to collect.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep#perfcounterdatasource'
  example: [
    '\\System\\Processes'
  ]
})
param performanceCounterSpecifiers array = []

@description('Optional. A list of specifier names for VM insights telemetry to collect.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep#perfcounterdatasource'
  example: [
    '\\VmInsights\\DetailedMetrics'
  ]
})
param insightsMetricsCounterSpecifiers array = []

@description('Optional. A list of Windows Event Log queries in XPATH format. Only applicable if kind is Windows.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep#windowseventlogdatasource'
  example: [
    'Microsoft-Windows-Shell-AuthUI-Shutdown/Diagnostic!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
  ]
})
param eventLogsxPathQueries array = []

@description('Optional. A friendly name for the destination. This name should be unique across all destinations (regardless of type) within the data collection rule.')
param destinationFriendlyName string = 'myloganalyticsworkspace'

@description('Optional. The specification of data flows.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep#dataflow'
  example: [
    {
      destinations: [
        'Destination-FriendlyName'
      ]
      streams: [
        'Microsoft-Event'
      ]
    }
  ]
})
param dataFlows array = [
  {
    destinations: [
      destinationFriendlyName
    ]
    streams: [
      'Microsoft-Event'
      'Microsoft-InsightsMetrics'
      'Microsoft-Perf'
      'Microsoft-Syslog'
    ]
  }
]

@description('Optional. The list of Azure VM extension data source configurations.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep#extensiondatasource'
  example: [
    {
      name: 'DependencyAgentDataSource'
      streams: [
        'Microsoft-ServiceMap'
      ]
      extensionName: 'DependencyAgent'
    }
  ]
})
param dcrExtensions array = []

var performanceCounters = [
  {
    name: 'insightsMetricsCounterSpecifiers'
    streams: [
      'Microsoft-InsightsMetrics'
    ]
    samplingFrequencyInSeconds: 60
    counterSpecifiers: insightsMetricsCounterSpecifiers
  }
  {
    name: 'perfCounterDataSource60'
    streams: [
      'Microsoft-Perf'
    ]
    samplingFrequencyInSeconds: 60
    counterSpecifiers: performanceCounterSpecifiers
  }
]

var windowsEventLogs = [
  {
    name: 'DS_WindowsEventLogs'
    streams: [
      'Microsoft-Event'
    ]
    xPathQueries: eventLogsxPathQueries
  }
]

var linuxSyslogs = [
  {
    name: 'sysLogsDataSource_${shortenedUniqueString}'
    streams: [
      'Microsoft-Syslog'
    ]
    facilityNames: [
      '*'
    ]
    logLevels: [
      'Debug'
      'Info'
      'Notice'
      'Warning'
      'Error'
      'Critical'
      'Alert'
      'Emergency'
    ]
  }
]

resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dataCollectionEndpointId: !empty(dataCollectionEndpointId) ? dataCollectionEndpointId : null
    dataSources: {
      performanceCounters: performanceCounters
      syslog: (kind == '' || kind == 'Windows') ? [] : linuxSyslogs
      windowsEventLogs: (kind == '' || kind == 'Linux') ? [] : windowsEventLogs
      extensions: dcrExtensions
    }
    dataFlows: dataFlows
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceId
          name: destinationFriendlyName
        }
      ]
    }
  }
}

@description('The resource id of the data collection rule (DCR).')
output dcrId string = dcr.id

@description('The principal id of the data collection rule for identity purposes.')
output dcrPrincipalId string = dcr.identity.principalId
