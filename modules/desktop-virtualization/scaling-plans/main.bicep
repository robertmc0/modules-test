metadata name = 'Desktop Virtualization Scaling Plan Module'
metadata description = 'This module deploys Desktop Virtualization Scaling Plan Module'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('Optional. Friendly name of scaling plan.')
param friendlyName string = ''

@description('Optional. Description for scaling plan.')
param scalingPlanDescription string = ''

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

@description('Optional. Exclusion tag for scaling plan.')
param exclusionTag string = ''

@description('List of HostPool resource Ids.')
param hostPoolReferences array

@description('Timezone of the scaling plan. E.g. "AUS Eastern Standard Time".')
param timeZone string

@description('List of scaling plan definitions.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.desktopvirtualization/scalingplans?pivots=deployment-language-bicep#scalingschedule'
  example: {
    name: 'string'
    daysOfWeek: 'string array'
    rampUpStartTime: {
      hour: 'int'
      minute: 'int'
    }
    rampUpLoadBalancingAlgorithm: 'string'
    rampUpMinimumHostsPct: 'int'
    rampUpCapacityThresholdPct: 'int'
    peakStartTime: {
      hour: 'int'
      minute: 'int'
    }
    peakLoadBalancingAlgorithm: 'string'
    rampDownStartTime: {
      hour: 'int'
      minute: 'int'
    }
    rampDownLoadBalancingAlgorithm: 'string'
    rampDownMinimumHostsPct: 'int'
    rampDownCapacityThresholdPct: 'int'
    rampDownWaitTimeMinutes: 'int'
    rampDownStopHostsWhen: 'string'
    rampDownNotificationMessage: 'string'

    offPeakStartTime: {
      hour: 'int'
      minute: 'int'
    }
    offPeakLoadBalancingAlgorithm: 'string'
    rampDownForceLogoffUsers: 'bool'
  }
})
param schedules array

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'AllLogs'
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

var lockName = toLower('${scalingPlan.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${scalingPlan.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

resource scalingPlan 'Microsoft.DesktopVirtualization/scalingPlans@2022-04-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    friendlyName: friendlyName
    description: scalingPlanDescription
    exclusionTag: exclusionTag
    hostPoolReferences: [for hostPool in hostPoolReferences: {
      hostPoolArmPath: hostPool
      scalingPlanEnabled: true
    }]
    hostPoolType: 'Pooled'
    timeZone: timeZone
    schedules: schedules
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: scalingPlan
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: scalingPlan
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
  }
}

@description('The name of the deployed scaling plan.')
output name string = scalingPlan.name

@description('The resource ID of the deployed scaling plan.')
output resourceId string = scalingPlan.id
