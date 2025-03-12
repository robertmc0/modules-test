metadata name = 'Automation Accounts Module'
metadata description = 'This module deploys Microsoft.Automation automationAccounts'
metadata owner = 'Arinco'

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

@description('Optional. SKU name of the account.')
@allowed([
  'Free'
  'Basic'
])
param sku string = 'Basic'

@description('Optional. Modules to import into automation account.')
@metadata({
  name: 'Module name.'
  version: 'Module version or specify latest to get the latest version.'
  uri: 'Module package uri, e.g. https://www.powershellgallery.com/api/v2/package.'
})
param modules array = []

@description('Optional. Variables to import into automation account.')
@metadata({
  name: 'Variable name.'
  #disable-next-line no-conflicting-metadata
  description: 'Variable Description.'
  isEncrypted: 'Variable is encypted.'
  value: 'Variable value.'
})
param variables array = []

@description('Optional. Runbooks to import into automation account.')
@metadata({
  runbookName: 'Runbook name.'
  runbookUri: 'Runbook URI.'
  runbookType: 'Runbook type: Graph, Graph PowerShell, Graph PowerShellWorkflow, PowerShell, PowerShell Workflow, Script.'
  logProgress: 'Enable progress logs.'
  logVerbose: 'Enable verbose logs.'
})
param runbooks array = []

@description('Optional. Schedules to import into automation account.')
@metadata({
  example: {
    name: 'auto-shutdown-1'
    description: 'Auto shutdown schedule'
    startTime: '2023-03-30T19:00:00+00:00'
    interval: 1
    frequency: 'Hour'
    timeZone: 'Australia/Canberra, Melbourne, Sydney' // IANA ID / Windows Time Zone ID
  }
})
param schedules array = []

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Update schedule configuration.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/softwareupdateconfigurations?pivots=deployment-language-bicep#property-values'
  example: {
    name: 'string'
    scheduleInfo: {
      startTime: 'string'
      frequency: 'string'
      timeZone: 'string'
      interval: 'int'
    }
    updateConfiguration: {
      operatingSystem: 'string'
      duration: 'string'
      targets: {
        azureQueries: [
          {
            locations: [
              'string'
            ]
            scope: [
              'string'
            ]
          }
        ]
      }
      windows: {
        includedUpdateClassifications: 'string, string'
      }
    }
  }
})
param updateScheduleConfig array = []

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'AllLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Event hub name. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubName string = ''

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${automationAccount.name}-${resourceLock}-lck')

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var diagnosticsName = toLower('${automationAccount.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    sku: {
      name: sku
    }
  }
}

@batchSize(1)
resource automationAccountModules 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = [for module in modules: {
  parent: automationAccount
  name: module.name
  properties: {
    contentLink: {
      uri: module.version == 'latest' ? '${module.uri}/${module.name}' : '${module.uri}/${module.name}/${module.version}'
      version: module.version == 'latest' ? null : module.version
    }
  }
}]

resource automationAccountVariables 'Microsoft.Automation/automationAccounts/variables@2022-08-08' = [for variable in variables: {
  name: variable.name
  parent: automationAccount
  properties: {
    description: variable.description
    isEncrypted: variable.isEncrypted
    value: variable.value
  }
}]

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = [for runbook in runbooks: {
  parent: automationAccount
  name: runbook.runbookName
  location: location
  properties: {
    runbookType: runbook.runbookType
    logProgress: runbook.logProgress
    logVerbose: runbook.logVerbose
    publishContentLink: {
      uri: runbook.runbookUri
    }
  }
}]

resource schedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = [for schedule in schedules: {
  parent: automationAccount
  dependsOn: [
    runbook
  ]
  name: schedule.name
  properties: {
    description: schedule.description
    startTime: schedule.startTime
    frequency: schedule.frequency
    interval: schedule.interval
    timeZone: schedule.timeZone
  }
}]

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = [for i in range(0, length(runbooks)): if (contains(runbooks[i], 'linkSchedule')) {
  parent: automationAccount
  name: guid(automationAccount.name, runbooks[i].runbookName)
  dependsOn: [
    schedule
  ]
  properties: {
    parameters: {}
    runbook: {
      name: runbooks[i].runbookName
    }
    schedule: {
      name: (contains(runbooks[i], 'linkSchedule')) ? runbooks[i].linkSchedule : ''
    }
  }
}]

resource updateConfiguration 'Microsoft.Automation/automationAccounts/softwareUpdateConfigurations@2019-06-01' = [for updateConfig in updateScheduleConfig: {
  parent: automationAccount
  name: updateConfig.name
  properties: updateConfig
}]

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: automationAccount
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: automationAccount
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed automation account.')
output name string = automationAccount.name

@description('The resource ID of the deployed automation account.')
output resourceId string = automationAccount.id

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(automationAccount.identity, 'principalId') ? automationAccount.identity.principalId : ''
