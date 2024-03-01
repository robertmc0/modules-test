/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('A name to define the DCR')
param name string = 'testdcr'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${uniqueString(deployment().name, location)}-law'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/

module dcrTestWindows '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-tst-win-dcr'
  params: {
    name: '${name}-win'
    location: location
    kind: 'Windows'
    workspaceId: logAnalyticsWorkspace.id
    dataFlows: [
      {
        destinations: [
          'myloganalyticsworkspace'
        ]
        streams: [
          'Microsoft-Event'
          'Microsoft-Perf'
        ]
      }
    ]
    eventLogsxPathQueries: [
      'Microsoft-Windows-Shell-AuthUI-Shutdown/Diagnostic!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
    ]
    insightsMetricsCounterSpecifiers: [
      '\\VmInsights\\DetailedMetrics'
    ]
    performanceCounterSpecifiers: [
      '\\System\\Processes'
    ]
  }
}

module dcrTestLinux '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-tst-linux-dcr'
  params: {
    name: '${name}-linux'
    location: location
    kind: 'Linux'
    workspaceId: logAnalyticsWorkspace.id
    dataFlows: [
      {
        destinations: [
          'myloganalyticsworkspace'
        ]
        streams: [
          'Microsoft-Perf'
          'Microsoft-Syslog'
        ]
      }
    ]
    insightsMetricsCounterSpecifiers: [
      '\\VmInsights\\DetailedMetrics'
    ]
    performanceCounterSpecifiers: [
      '\\System\\Processes'
    ]
  }
}

module dcrTestMutliOs '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-tst-multi-dcr'
  params: {
    name: '${name}-multiOs'
    location: location
    workspaceId: logAnalyticsWorkspace.id
  }
}
