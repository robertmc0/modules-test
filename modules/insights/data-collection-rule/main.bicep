metadata name = 'Insights data collection rule Module.'
metadata description = 'This module deploys Microsoft.Insights dataCollectionRules.'
metadata owner = 'Arinco'

// Global parameters //

@description('Required. Name of the Data collection rule.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Required. Resource ID of the Log Analytics Workspace that has the VM Insights data.')
param workspaceId string

@description('Optional. A random generated set of strings for resource naming.')
param shortenedUniqueString string = substring(uniqueString(utcNow()), 0, 4)

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

// Data collection settings parameters //

@description('Required. The operating system kind in which DCR will be configured to.')
@allowed([
  'Windows'
  'Linux'
  'All'
])
param kind string

@description('Required. The resource ID of the data collection endpoint that this rule can be used with.')
param dataCollectionEndpointId string = ''

/* For the DCR to be any useful, it should report System telemetry. Additional entries can be added by parsing params to this module. */
@description('Optional. A list of specifier names for VM Performance telemetry to collect.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep#perfcounterdatasource'
  example: [
    '\\System\\Processes'
  ]
})
param performanceCounterSpecifiers array = [
  '\\System\\Processes'
]

/* For the DCR to be any useful, it should report some VM metrics telemetry. Additional entries can be added by parsing params to this module. */
@description('Optional. A list of specifier names for VM insights telemetry to collect.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep#perfcounterdatasource'
  example: [
    '\\VmInsights\\DetailedMetrics'
  ]
})
param insightsMetricsCounterSpecifiers array = [
  '\\VmInsights\\DetailedMetrics'
]

/* Default values defined with the standard telemetry set. This can be over written if desired. */
@description('Optional. A list of Windows Event Log queries in XPATH format. Only applicable if kind is Windows.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep#windowseventlogdatasource'
  example: [
    'Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
    'Security!*[System[(band(Keywords,13510798882111488))]]'
    'System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
  ]
})
param eventLogsxPathQueries array = [
  'Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
  'Security!*[System[(band(Keywords,13510798882111488))]]'
  'System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
]

@description('Optional. A friendly name for the destination. This name should be unique across all destinations (regardless of type) within the data collection rule.')
param destinationFriendlyName string = 'myloganalyticsworkspace'

/* Standard set of data streams defined by default. This can be over written if desired. */
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

/* Not a requirement, unless if you have VM extensions want them to be parsed through for logging */
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
    counterSpecifiers: !empty(insightsMetricsCounterSpecifiers)
      ? insightsMetricsCounterSpecifiers
      : ['\\VmInsights\\DetailedMetrics'] // Cannot be empty
  }
  {
    name: 'perfCounterDataSource60'
    streams: [
      'Microsoft-Perf'
    ]
    samplingFrequencyInSeconds: 60
    counterSpecifiers: !empty(performanceCounterSpecifiers) ? performanceCounterSpecifiers : ['\\System\\Processes'] // Cannot be empty
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

resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' =
  if (kind != 'All') {
    name: name
    location: location
    tags: tags
    kind: kind
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      dataCollectionEndpointId: !empty(dataCollectionEndpointId) ? dataCollectionEndpointId : null
      dataSources: {
        performanceCounters: performanceCounters
        syslog: (kind == 'Linux') ? linuxSyslogs : []
        windowsEventLogs: (kind == 'Windows') ? windowsEventLogs : []
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

resource dcrMultiOs 'Microsoft.Insights/dataCollectionRules@2022-06-01' =
  if (kind == 'All') {
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
        syslog: linuxSyslogs
        windowsEventLogs: windowsEventLogs
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
output resourceId string = dcr.id

@description('The resource name of the data collection rule (DCR).')
output name string = dcr.name

@description('The system assigned principal id of the data collection rule for identity purposes.')
output systemAssignedPrincipalId string = dcr.identity.principalId
