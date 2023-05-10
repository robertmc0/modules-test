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

@description('Optional. Administrator username for the server. Once created it cannot be changed. Required if "administrators" is not provided.')
param administratorLogin string = ''

@description('Optional. The administrator login password. Required if "administrators" is not provided.')
@secure()
param administratorLoginPassword string = ''

@description('Optional. The Azure Active Directory administrator of the server. Required if "administratorLogin" and "administratorLoginPassword" is not provided.')
@metadata(
  {
    doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#serverexternaladministrator'
    example: {
      azureADOnlyAuthentication: true
      login: 'joe.bloggs@microsoft.com'
      objectId: '5be5d82b-4e7b-4c4a-8811-c51982b435e0'
    }
    example2: {
      azureADOnlyAuthentication: true
      login: 'Group Name'
      principalType: 'Group'
      objectId: '3c1060a3-7f8a-47bc-8fb0-375d3bfff7a1'
    }
  }
)
param administrators object = {}

@description('Optional. Whether or not public endpoint access is allowed for this server. Only Disable if you wish to restrict to just private endpoints and VNET.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. The server connection type. Note private link requires Proxy.')
@allowed([
  'Default'
  'Proxy'
  'Redirect'
])
param connectionType string = 'Default'

@description('Optional. Enable Vulnerability Assessments. Not currently supported with user managed identities.')
param enableVulnerabilityAssessments bool = false

@description('Optional. Resource ID of the Storage Account to store Vulnerability Assessments. Required when enableVulnerabilityAssessments set to "true". ')
param vulnerabilityAssessmentStorageId string = ''

@description('Optional. Enable Audit logging.')
param enableAudit bool = false

@description('Optional. Resource ID of the Storage Account to store Audit logs. Required when enableAudit set to "true".')
param auditStorageAccountId string = ''

@description('Optional. Specifies that the schedule scan notification will be is sent to the subscription administrators.')
param emailAccountAdmins bool = false

@description('Optional. Specifies an array of e-mail addresses to which the scan notification is sent.')
param emailAddresses array = []

@description('Optional. Resource ID of the virtual network subnet to configure as a virtual network rule.')
param subnetResourceId string = ''

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. The resource ID of a user assigned identity to be used by default.')
param primaryUserAssignedIdentityId string = ''

@description('Optional. Specifies the number of days to keep in the Threat Detection audit logs. Zero means keep forever.')
param threatDetectionRetentionDays int = 0

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'DevopsOperationsAudit'
  'SQLSecurityAuditEvents'
  'AutomaticTuning'
  'QueryStoreRuntimeStatistics'
  'QueryStoreWaitStatistics'
  'Errors'
  'DatabaseWaitStatistics'
  'Timeouts'
  'Blocks'
  'Deadlocks'
])
param diagnosticLogCategoriesToEnable array = [
  'DevopsOperationsAudit'
  'SQLSecurityAuditEvents'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'Basic'
  'InstanceAndAppAdvanced'
  'WorkloadManagement'
])
param diagnosticMetricsToEnable array = [
  'Basic'
  'InstanceAndAppAdvanced'
  'WorkloadManagement'
]

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

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

var vulnerabilityAssessmentStorageResourceGroup = enableVulnerabilityAssessments ? split(vulnerabilityAssessmentStorageId, '/')[4] : 'placeholder' // must contain placeholder value as it is evaulated as part of the scope of the role assignment module

var vulnerabilityAssessmentStorageSubId = enableVulnerabilityAssessments ? split(vulnerabilityAssessmentStorageId, '/')[2] : 'placeholder' // must contain placeholder value as it is evaulated as part of the scope of the role assignment module

var vulnerabilityAssessmentStorageName = enableVulnerabilityAssessments ? last(split(vulnerabilityAssessmentStorageId, '/')) : null

var auditStorageResourceGroup = enableAudit ? split(auditStorageAccountId, '/')[4] : 'placeholder' // must contain placeholder value as it is evaulated as part of the scope of the role assignment module

var auditStorageSubId = enableAudit ? split(auditStorageAccountId, '/')[2] : 'placeholder' // must contain placeholder value as it is evaulated as part of the scope of the role assignment module

var auditStorageName = enableAudit ? last(split(auditStorageAccountId, '/')) : null

var userIdentityResourceGroup = !empty(primaryUserAssignedIdentityId) ? split(primaryUserAssignedIdentityId, '/')[4] : null

var userIdentitySubId = !empty(primaryUserAssignedIdentityId) ? split(primaryUserAssignedIdentityId, '/')[2] : null

var userIdentityName = !empty(primaryUserAssignedIdentityId) ? last(split(primaryUserAssignedIdentityId, '/')) : null

var lockName = toLower('${sqlServer.name}-${resourceLock}-lck')

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: enableVulnerabilityAssessments && !empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : enableVulnerabilityAssessments && empty(userAssignedIdentities) ? 'SystemAssigned' : identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var diagnosticsName = toLower('${sqlServer.name}-dgs')

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var auditActionsAndGroups = [
  'BATCH_COMPLETED_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
]

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = if (!empty(primaryUserAssignedIdentityId)) {
  scope: resourceGroup(userIdentitySubId, userIdentityResourceGroup)
  name: userIdentityName
}

resource vulnerabilityAssessmentStorage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if (enableVulnerabilityAssessments) {
  scope: resourceGroup(vulnerabilityAssessmentStorageSubId, vulnerabilityAssessmentStorageResourceGroup)
  name: vulnerabilityAssessmentStorageName
}

module vulnerabilityAssessmentRoleAssignment 'roleAssignment.bicep' = if (enableVulnerabilityAssessments && !empty(identity)) {
  scope: resourceGroup(vulnerabilityAssessmentStorageSubId, vulnerabilityAssessmentStorageResourceGroup)
  name: 'vulnerabilityAssessmentRoleAssignment'
  params: {
    storageAccountName: vulnerabilityAssessmentStorageName
    principalId: sqlServer.identity.principalId
  }
}

resource auditStorage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if (enableAudit) {
  scope: resourceGroup(auditStorageSubId, auditStorageResourceGroup)
  name: auditStorageName
}

module auditStorageRoleAssignment 'roleAssignment.bicep' = if (enableAudit && !empty(identity)) {
  scope: resourceGroup(auditStorageSubId, auditStorageResourceGroup)
  name: 'auditStorageRoleAssignment'
  params: {
    storageAccountName: auditStorageName
    principalId: !empty(primaryUserAssignedIdentityId) ? userIdentity.properties.principalId : sqlServer.identity.principalId
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    administratorLogin: !empty(administratorLogin) ? administratorLogin : null
    administratorLoginPassword: !empty(administratorLoginPassword) ? administratorLoginPassword : null
    administrators: !empty(administrators) ? {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: contains(administrators, 'azureADOnlyAuthentication') ? administrators.azureADOnlyAuthentication : true
      login: administrators.login
      principalType: contains(administrators, 'principalType') ? administrators.principalType : null
      sid: administrators.objectId
      tenantId: contains(administrators, 'tenantId') ? administrators.tenantId : subscription().tenantId
    } : {}
    version: '12.0'
    publicNetworkAccess: publicNetworkAccess
    minimalTlsVersion: '1.2'
    primaryUserAssignedIdentityId: primaryUserAssignedIdentityId
  }
}

resource virtualNetworkRules 'Microsoft.Sql/servers/virtualNetworkRules@2021-11-01' = if (!empty(subnetResourceId)) {
  parent: sqlServer
  name: 'default'
  properties: {
    virtualNetworkSubnetId: subnetResourceId
  }
}

resource connectionPolicy 'Microsoft.Sql/servers/connectionPolicies@2021-11-01' = {
  parent: sqlServer
  name: 'default'
  properties: {
    connectionType: connectionType

  }
}

resource securityThreatAlertPolicies 'Microsoft.Sql/servers/securityAlertPolicies@2021-11-01' = {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    emailAccountAdmins: emailAccountAdmins
    emailAddresses: emailAddresses
    retentionDays: threatDetectionRetentionDays
  }
}

resource vulnerabilityAssessments 'Microsoft.Sql/servers/vulnerabilityAssessments@2021-11-01' = if (enableVulnerabilityAssessments) {
  parent: sqlServer
  name: 'default'
  properties: {
    storageContainerPath: enableVulnerabilityAssessments ? '${vulnerabilityAssessmentStorage.properties.primaryEndpoints.blob}vulnerability-assessment' : ''
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: emailAccountAdmins
      emails: emailAddresses
    }
  }
  dependsOn: [
    securityThreatAlertPolicies
    vulnerabilityAssessmentRoleAssignment
  ]
}

resource auditSettings 'Microsoft.Sql/servers/auditingSettings@2021-11-01' = if (enableAudit) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    auditActionsAndGroups: auditActionsAndGroups
    isAzureMonitorTargetEnabled: true
    isManagedIdentityInUse: true
    isDevopsAuditEnabled: true
    storageEndpoint: enableAudit ? auditStorage.properties.primaryEndpoints.blob : null
    storageAccountSubscriptionId: auditStorageSubId
  }
  dependsOn: [
    auditStorageRoleAssignment
  ]
}

resource microsoftSupportAuditSettings 'Microsoft.Sql/servers/devOpsAuditingSettings@2021-11-01' = if (enableAudit) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
    storageEndpoint: enableAudit ? auditStorage.properties.primaryEndpoints.blob : null
    storageAccountSubscriptionId: auditStorageSubId
  }
  dependsOn: [
    auditStorageRoleAssignment
  ]
}

resource sqlServerMasterDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  location: location
  name: 'master'
  properties: {}
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: sqlServerMasterDatabase
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
  scope: sqlServer
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the sql server.')
output name string = sqlServer.name

@description('The resource ID of the sql server.')
output resourceId string = sqlServer.id

@description('The resource group the sql server was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(sqlServer.identity, 'principalId') ? sqlServer.identity.principalId : ''
