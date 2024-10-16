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

module dcrTestWindowsMinimalMetrics '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-win-minimal-dcr'
  params: {
    name: '${name}-win-minimal-dcr'
    location: location
    kind: 'Windows'
    workspaceId: logAnalyticsWorkspace.id
    resourceLock: 'ReadOnly'
  }
}

module dcrTestLinuxMinimalMetrics '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-lin-minimal-dcr'
  params: {
    name: '${name}-lin-minimal-dcr'
    location: location
    kind: 'Linux'
    workspaceId: logAnalyticsWorkspace.id
    resourceLock: 'ReadOnly'
  }
}

module dcrTestMultiOsMinimalMetrics '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-multiOs-minimal-dcr'
  params: {
    name: '${name}-multiOs-minimal-dcr'
    location: location
    kind: 'All'
    workspaceId: logAnalyticsWorkspace.id
    resourceLock: 'ReadOnly'
  }
}

module dcrTestWindowsFull '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-win-full-dcr'
  params: {
    name: '${name}-win-all-metrics'
    location: location
    kind: 'Windows'
    workspaceId: logAnalyticsWorkspace.id
    resourceLock: 'ReadOnly'
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
      'Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
      'Security!*[System[(band(Keywords,13510798882111488))]]'
      'System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
    ]
    insightsMetricsCounterSpecifiers: [
      '\\VmInsights\\DetailedMetrics'
    ]
    performanceCounterSpecifiers: [
      '\\Processor Information(_Total)\\% Processor Time'
      '\\Processor Information(_Total)\\% Privileged Time'
      '\\Processor Information(_Total)\\% User Time'
      '\\Processor Information(_Total)\\Processor Frequency'
      '\\System\\Processes'
      '\\Process(_Total)\\Thread Count'
      '\\Process(_Total)\\Handle Count'
      '\\System\\System Up Time'
      '\\System\\Context Switches/sec'
      '\\System\\Processor Queue Length'
      '\\Memory\\% Committed Bytes In Use'
      '\\Memory\\Available Bytes'
      '\\Memory\\Committed Bytes'
      '\\Memory\\Cache Bytes'
      '\\Memory\\Pool Paged Bytes'
      '\\Memory\\Pool Nonpaged Bytes'
      '\\Memory\\Pages/sec'
      '\\Memory\\Page Faults/sec'
      '\\Process(_Total)\\Working Set'
      '\\Process(_Total)\\Working Set - Private'
      '\\LogicalDisk(_Total)\\% Disk Time'
      '\\LogicalDisk(_Total)\\% Disk Read Time'
      '\\LogicalDisk(_Total)\\% Disk Write Time'
      '\\LogicalDisk(_Total)\\% Idle Time'
      '\\LogicalDisk(_Total)\\Disk Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Read Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Write Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Transfers/sec'
      '\\LogicalDisk(_Total)\\Disk Reads/sec'
      '\\LogicalDisk(_Total)\\Disk Writes/sec'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Read'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Write'
      '\\LogicalDisk(_Total)\\Avg. Disk Queue Length'
      '\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length'
      '\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length'
      '\\LogicalDisk(_Total)\\% Free Space'
      '\\LogicalDisk(_Total)\\Free Megabytes'
      '\\Network Interface(*)\\Bytes Total/sec'
      '\\Network Interface(*)\\Bytes Sent/sec'
      '\\Network Interface(*)\\Bytes Received/sec'
      '\\Network Interface(*)\\Packets/sec'
      '\\Network Interface(*)\\Packets Sent/sec'
      '\\Network Interface(*)\\Packets Received/sec'
      '\\Network Interface(*)\\Packets Outbound Errors'
      '\\Network Interface(*)\\Packets Received Errors'
    ]
  }
}

module dcrTestLinux '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-linux-full-dcr'
  params: {
    name: '${name}-linux'
    location: location
    kind: 'Linux'
    workspaceId: logAnalyticsWorkspace.id
    resourceLock: 'ReadOnly'
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
      '\\Processor Information(_Total)\\% Processor Time'
      '\\Processor Information(_Total)\\% Privileged Time'
      '\\Processor Information(_Total)\\% User Time'
      '\\Processor Information(_Total)\\Processor Frequency'
      '\\System\\Processes'
      '\\Process(_Total)\\Thread Count'
      '\\Process(_Total)\\Handle Count'
      '\\System\\System Up Time'
      '\\System\\Context Switches/sec'
      '\\System\\Processor Queue Length'
      '\\Memory\\% Committed Bytes In Use'
      '\\Memory\\Available Bytes'
      '\\Memory\\Committed Bytes'
      '\\Memory\\Cache Bytes'
      '\\Memory\\Pool Paged Bytes'
      '\\Memory\\Pool Nonpaged Bytes'
      '\\Memory\\Pages/sec'
      '\\Memory\\Page Faults/sec'
      '\\Process(_Total)\\Working Set'
      '\\Process(_Total)\\Working Set - Private'
      '\\LogicalDisk(_Total)\\% Disk Time'
      '\\LogicalDisk(_Total)\\% Disk Read Time'
      '\\LogicalDisk(_Total)\\% Disk Write Time'
      '\\LogicalDisk(_Total)\\% Idle Time'
      '\\LogicalDisk(_Total)\\Disk Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Read Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Write Bytes/sec'
      '\\LogicalDisk(_Total)\\Disk Transfers/sec'
      '\\LogicalDisk(_Total)\\Disk Reads/sec'
      '\\LogicalDisk(_Total)\\Disk Writes/sec'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Read'
      '\\LogicalDisk(_Total)\\Avg. Disk sec/Write'
      '\\LogicalDisk(_Total)\\Avg. Disk Queue Length'
      '\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length'
      '\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length'
      '\\LogicalDisk(_Total)\\% Free Space'
      '\\LogicalDisk(_Total)\\Free Megabytes'
      '\\Network Interface(*)\\Bytes Total/sec'
      '\\Network Interface(*)\\Bytes Sent/sec'
      '\\Network Interface(*)\\Bytes Received/sec'
      '\\Network Interface(*)\\Packets/sec'
      '\\Network Interface(*)\\Packets Sent/sec'
      '\\Network Interface(*)\\Packets Received/sec'
      '\\Network Interface(*)\\Packets Outbound Errors'
      '\\Network Interface(*)\\Packets Received Errors'
    ]
  }
}
