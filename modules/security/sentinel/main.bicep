metadata name = 'Sentinel Module'
metadata description = 'This module deploys Azure Sentinel'
metadata owner = 'Arinco'

@description('The geo-location where the resource lives.')
param location string

@description('Log analytics workspace resource ID.')
param workspaceId string

@description('Optional. Data sources to add to Sentinel.')
@metadata({
  name: 'Data source name.'
  kind: 'Data source kind.'
  properties: 'The data source properties in raw json format, each kind of data source have its own schema.'
})
param dataSources array = [
  {
    name: 'SecurityInsightsSecurityEventCollectionConfiguration'
    kind: 'SecurityInsightsSecurityEventCollectionConfiguration'
    properties: {
      tier: 'All'
      tierSetMethod: 'Custom'
    }
  }
  {
    name: 'LinuxSyslogCollection'
    kind: 'LinuxSyslogCollection'
    properties: {
      state: 'enabled'
    }
  }
  {
    name: 'IISLogs'
    kind: 'IISLogs'
    properties: {
      state: 'OnPremiseEnabled'
    }
  }
]

@description('Optional. Connectors to be added to Sentinel.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.securityinsights/dataconnectors?pivots=deployment-language-bicep'
  example: {
    kind: 'AzureActiveDirectory'
    properties: {
      dataTypes: {
        alerts: {
          state: 'string'
        }
      }
      tenantId: 'string'
    }
  }
})
param connectors array = []

@description('Optional. Incident creation alert rules to be added to Sentinel.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.securityinsights/alertrules?pivots=deployment-language-bicep'
  example: {
    kind: 'ThreatIntelligence'
    properties: {
      alertRuleTemplateName: 'string'
      enabled: 'bool'
    }
  }
})
param alertRules array = [
  {
    name: 'mlrdp'
    kind: 'MLBehaviorAnalytics'
    properties: {
      enabled: true
      alertRuleTemplateName: '737a2ce1-70a3-4968-9e90-3e6aca836abf'
    }
  }

  {
    name: 'fusion'
    kind: 'Fusion'
    properties: {
      enabled: true
      alertRuleTemplateName: 'f71aba3d-28fb-450b-b192-4e76a83015c8'
    }
  }
  {
    name: 'mlssh'
    kind: 'MLBehaviorAnalytics'
    properties: {
      enabled: true
      alertRuleTemplateName: 'fa118b98-de46-4e94-87f9-8e6d5060b60b'
    }
  }
]

@description('Optional. A list of Windows Event Providers that you would like to collect. Windows Security Auditing is not enabled through this option. It is enabled through Azure Sentinel Data Connectors.')
param winEventProviders array = [
  'Microsoft-Windows-Sysmon/Operational'
  'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational'
  'Microsoft-Windows-Bits-Client/Operational'
  'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'
  'Directory Service'
  'Microsoft-Windows-DNS-Client/Operational'
  'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall'
  'Windows PowerShell'
  'Microsoft-Windows-PowerShell/Operational'
  'Microsoft-Windows-WMI-Activity/Operational'
  'Microsoft-Windows-TaskScheduler/Operational'
]

@description('Optional. A list of Windows Event Types that you would like to collect.')
@metadata({
  eventType: 'string'
})
param winEventTypes array = [
  {
    eventType: 'Error'
  }
  {
    eventType: 'Warning'
  }
  {
    eventType: 'Information'
  }
]

@description('Optional. A list of facilities to collect from Syslog.')
param syslogFacilities array = [
  'auth'
  'authpriv'
  'cron'
  'daemon'
  'ftp'
  'kern'
  'user'
  'mail'
]

@description('Optional. A list of severities to collect from Syslog.')
@metadata({
  severity: 'string'
})
param syslogSeverities array = [
  {
    severity: 'emerg'
  }
  {
    severity: 'alert'
  }
  {
    severity: 'crit'
  }
  {
    severity: 'err'
  }
  {
    severity: 'warning'
  }
  {
    severity: 'notice'
  }
  {
    severity: 'info'
  }
  {
    severity: 'debug'
  }
]

var workspaceName = last(split(workspaceId, '/'))

resource sentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspaceName})'
  location: location
  properties: {
    workspaceResourceId: workspaceId
  }
  plan: {
    name: 'SecurityInsights(${workspaceName})'
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}

resource sentinelOnboarding 'Microsoft.SecurityInsights/onboardingStates@2024-03-01' = {
  dependsOn: [sentinelSolution]
  scope: logAnalytics
  name: 'default'
}

resource sentinelDataSources 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [
  for dataSource in dataSources: {
    parent: logAnalytics
    name: dataSource.name
    kind: dataSource.kind
    properties: dataSource.properties
  }
]

resource sentinelDataSourceWinEvent 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [
  for provider in winEventProviders: {
    parent: logAnalytics
    name: 'winEvent${replace(provider, '/', '')}'
    kind: 'WindowsEvent'
    properties: {
      eventLogName: provider
      eventTypes: winEventTypes
    }
  }
]

resource sentinelDataSourceSyslog 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [
  for facility in syslogFacilities: {
    parent: logAnalytics
    name: 'syslog${replace(facility, '/', '')}'
    kind: 'LinuxSyslog'
    properties: {
      sysLogName: facility
      syslogSeverities: syslogSeverities
    }
  }
]

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: workspaceName
}

resource sentinelConnectors 'Microsoft.SecurityInsights/dataConnectors@2024-03-01' = [
  for connector in connectors: {
    dependsOn: [sentinelOnboarding]
    scope: logAnalytics
    name: '${connector.kind}${uniqueString(resourceGroup().id)}'
    location: location
    kind: connector.kind
    properties: connector.properties
  }
]

resource sentinelAlertRules 'Microsoft.SecurityInsights/alertRules@2024-03-01' = [
  for rule in alertRules: {
    dependsOn: [sentinelOnboarding]
    scope: logAnalytics
    name: guid(rule.name)
    kind: rule.kind
    location: location
    properties: rule.properties
  }
]
