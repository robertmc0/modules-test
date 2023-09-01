metadata name = 'Desktop Virtualization Application Group Module'
metadata description = 'This module deploys Microsoft.DesktopVirtualization Application Groups'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('Optional. Friendly name of ApplicationGroup.')
param friendlyName string = ''

@description('Optional. Description for ApplicationGroup.')
param applicationGroupDescription string = ''

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

@description('Resource Type of ApplicationGroup.')
@allowed([
  'Desktop'
  'RemoteApp'
])
param applicationGroupType string

@description('HostPool arm path of ApplicationGroup.')
param hostPoolArmPath string

@description('Optional. RemoteApps to add to ApplicationGroup.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.desktopvirtualization/applicationgroups/applications?pivots=deployment-language-bicep#applicationproperties'
  example: {
    name: 'string'
    applicationType: 'string'
    commandLineArguments: 'string'
    commandLineSetting: 'string'
    description: 'string'
    filePath: 'string'
    friendlyName: 'string'
    iconIndex: 'int'
    iconPath: 'string'
    msixPackageApplicationId: 'string'
    msixPackageFamilyName: 'string'
    showInPortal: 'bool'
  }
})
param remoteApps array = []

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

var lockName = toLower('${applicationGroup.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${applicationGroup.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
}]

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' = {
  name: name
  location: location
  tags: tags

  properties: {
    friendlyName: friendlyName
    description: applicationGroupDescription
    applicationGroupType: applicationGroupType
    hostPoolArmPath: hostPoolArmPath
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: applicationGroup
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: applicationGroup
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
  }
}

resource remoteApplications 'Microsoft.DesktopVirtualization/applicationGroups/applications@2022-04-01-preview' = [for app in remoteApps: {
  parent: applicationGroup
  name: app.name
  properties: {
    applicationType: contains(app, 'applicationType') ? app.applicationType : ''
    commandLineArguments: contains(app, 'commandLineArguments') ? app.commandLineArguments : ''
    commandLineSetting: contains(app, 'commandLineSetting') ? app.commandLineSetting : ''
    description: contains(app, 'description') ? app.description : ''
    filePath: contains(app, 'filePath') ? app.filePath : ''
    friendlyName: contains(app, 'friendlyName') ? app.friendlyName : ''
    iconIndex: contains(app, 'iconIndex') ? app.iconIndex : 0
    iconPath: contains(app, 'iconPath') ? app.iconPath : null
    msixPackageApplicationId: contains(app, 'msixPackageApplicationId') ? app.msixPackageApplicationId : null
    msixPackageFamilyName: contains(app, 'msixPackageFamilyName') ? app.msixPackageFamilyName : null
    showInPortal: contains(app, 'showInPortal') ? app.showInPortal : true
  }
}]

@description('The name of the deployed application group.')
output name string = applicationGroup.name

@description('The resource ID of the deployed application group.')
output resourceId string = applicationGroup.id
