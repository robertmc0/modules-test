// Azure SQL Server only.  Create Databases, Threat Protection and Audit settings seperately

@description('Name of the Azure SQL resource.')
param name string

@description('Location of the resource.')
param location string

@description('Optional. Administrator username for the server. Required if no `administrators` object for AAD authentication is provided.')
param administratorLogin string = ''

@description('Optional. The administrator login password. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param administratorLoginPassword string = ''

@description('Optional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided.')
@metadata(
  { 
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


@description('Enable/Disable Public Network Access. Only Disable if you wish to restrict to just private endpoints and VNET.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. The server connection type. - Default, Proxy, Redirect.  Note private link requires Proxy.')
@allowed([
  'Default'
  'Proxy'
  'Redirect'
])
param connectionType string = 'Default'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Name of Storage Account to store Vulnerability Assessments.')
param vulnerabilityAssessmentStorageAccountName string

@description('Resource Group of Storage Account to store Vulnerability Assessments.')
param vulnerabilityAssessmentStorageResourceGroup string = resourceGroup().name

@description('Subscription Id of Storage Account to store Vulnerability Assessments.')
param vulnerabilityAssessmentStorageSubscriptionId string = subscription().subscriptionId

@description('Optional. Specifies that the alert is sent to the account/subscription administrators.')
param emailAccountAdmins bool = false

@description('Array of e-mail addresses to which the alert and vulnerability scans are sent.')
param emailAddresses array = []

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param resourcelock  string = 'NotSpecified'

@description('Optional. The full resource ID of a subnet in a virtual network to deploy the API Management service in.')
param subnetResourceId string = ''

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. Specifies the number of days to keep in the audit logs. Zero means keep forever.')
param threatDetectionRetentionDays int = 0

@description('Optional. The ID(s) to assign to the resource.')
@metadata({
  example: {
    '/subscriptions/<subscription>/resourceGroups/<rgp>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-umi': {}
  }
})
param userAssignedIdentities object = {}

@description('Optional. Enable audit logs')
param enableAudit bool = false

@description('Optional. Resource ID of the audit log analytics workspace.')
param auditLogAnalyticsWorkspaceId string = ''

@description('Optional. Resource ID of the audit event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param auditEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the audit event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param auditEventHubName string = ''

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param auditLogsRetentionInDays int = 365

@description('Name of Storage Account to store audit logs.')
param auditStorageAccountName string

@description('Resource Group of Storage Account to store audit logs.')
param auditStorageResourceGroup string = resourceGroup().name

@description('Subscription Id of Storage Account to store audit logs.')
param auditStorageSubscriptionId string = subscription().subscriptionId


var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var lockName = toLower('${sqlServer.name}-${resourcelock}-lck')

var auditActionsAndGroups = [
  'BATCH_COMPLETED_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
]

var diagnosticsName = '${sqlServer.name}-dgs'

var diagnosticLogCategoriesToEnable = [
    'DevOpsOperationsAudit'
    'SQLSecurityAuditEvents'
  ]

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: auditLogsRetentionInDays
  }
}]

resource vulnerabilityAssessmentStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(vulnerabilityAssessmentStorageSubscriptionId,vulnerabilityAssessmentStorageResourceGroup)
  name: vulnerabilityAssessmentStorageAccountName
}

module vulnerabilityAssessmentRoleAssignment 'roleAssignment.bicep' = {
  scope: resourceGroup(vulnerabilityAssessmentStorageSubscriptionId,vulnerabilityAssessmentStorageResourceGroup)
  name: 'vulnerabilityAssessmentRoleAssignment'
  params: {
    storageAccountName: vulnerabilityAssessmentStorageAccountName
    principalId: sqlServer.identity.principalId
  }
}

resource auditStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing =  {
  scope: resourceGroup(auditStorageSubscriptionId,auditStorageResourceGroup)
  name: auditStorageAccountName
}

module auditStorageRoleAssignment 'roleAssignment.bicep' = {
  scope: resourceGroup(auditStorageSubscriptionId, auditStorageResourceGroup)
  name: 'auditStorageRoleAssignment'
  params: {
    storageAccountName: auditStorageAccountName
    principalId: sqlServer.identity.principalId
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    administratorLogin: !empty(administratorLogin) ? administratorLogin : null
    administratorLoginPassword: !empty(administratorLoginPassword) ? administratorLoginPassword : null
    administrators: !empty(administrators) ? {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication:  contains(administrators, 'azureADOnlyAuthentication') ? administrators.azureADOnlyAuthentication : true
      login: administrators.login
      principalType: contains(administrators, 'principalType') ? administrators.principalType : null
      sid: administrators.objectId
      tenantId: contains(administrators, 'tenantId') ? administrators.tenantId : subscription().tenantId
    } : null
    version: '12.0'
    publicNetworkAccess: publicNetworkAccess
    minimalTlsVersion: '1.2'
  }
}

resource virtualNetworkRules 'Microsoft.Sql/servers/virtualNetworkRules@2021-11-01-preview' = if (!empty(subnetResourceId)) {
  parent: sqlServer
  name: 'default'
  properties: {
    virtualNetworkSubnetId: subnetResourceId
  }
}

resource connectionPolicy 'Microsoft.Sql/servers/connectionPolicies@2021-11-01-preview' = {
  parent: sqlServer
  name: 'default'
  properties: {
    connectionType: connectionType
  }
}

resource securityThreatAlertPolicies 'Microsoft.Sql/servers/securityAlertPolicies@2021-11-01-preview' = {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
    emailAccountAdmins: emailAccountAdmins
    emailAddresses: emailAddresses
    retentionDays: threatDetectionRetentionDays
  }
}

resource vulnerabilityAssessments 'Microsoft.Sql/servers/vulnerabilityAssessments@2021-11-01-preview' = {
  parent: sqlServer
  name: 'default'
  properties: {
    storageContainerPath: '${vulnerabilityAssessmentStorage.properties.primaryEndpoints.blob}vulnerability-assessment'
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

resource auditSettings 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview' = if(enableAudit) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    auditActionsAndGroups: auditActionsAndGroups
    isAzureMonitorTargetEnabled: empty(auditStorage) ? true : false
    isDevopsAuditEnabled: true
    storageEndpoint: !empty(auditStorage) ? auditStorage.properties.primaryEndpoints.blob : null
    storageAccountSubscriptionId: auditStorageSubscriptionId
  }
  dependsOn: [
    auditStorageRoleAssignment
  ]
}

resource microsoftSupportAuditSettings 'Microsoft.Sql/servers/devOpsAuditingSettings@2021-11-01-preview' = if(enableAudit) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: empty(auditStorage) ? true : false
    storageEndpoint: !empty(auditStorage) ? auditStorage.properties.primaryEndpoints.blob : null
    storageAccountSubscriptionId: auditStorageSubscriptionId
  }
  dependsOn: [
    auditStorageRoleAssignment
  ]
}

// Define master database as a resource to enable server level security auditing
resource sqlServerMasterDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  location: location
  name: 'master'
  properties: {}
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableAudit && (!empty(auditLogAnalyticsWorkspaceId) || (!empty(auditEventHubAuthorizationRuleId) || !empty(auditEventHubName)))) {
  scope: sqlServerMasterDatabase
  name: diagnosticsName
  properties: {
    workspaceId: empty(auditLogAnalyticsWorkspaceId) ? null : auditLogAnalyticsWorkspaceId
    storageAccountId: empty(auditStorage) ? null : auditStorage.id
    eventHubAuthorizationRuleId: empty(auditEventHubAuthorizationRuleId) ? null : auditEventHubAuthorizationRuleId
    eventHubName: empty(auditEventHubName) ? null : auditEventHubName
    logs: diagnosticsLogs
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: sqlServer
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the sql server')
output name string = sqlServer.name
@description('The resource ID of the sql server')
output resourceId string = sqlServer.id
@description('The resource group the API management service was deployed into')
output resourceGroupName string = resourceGroup().name
@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(sqlServer.identity, 'principalId') ? sqlServer.identity.principalId : ''
