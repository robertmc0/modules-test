@description('The name of the Managed Instance.')
@maxLength(63)
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

@description('Specifies the sku of the managed instance.')
@allowed([
  'GP_Gen5'
  'GP_G8IM'
  'GP_G8IH'
  'BC_Gen5'
  'BC_G8IM'
  'BC_G8IH'
])
param skuName string

@description('Specifies the number of vCores provisioned.')
@allowed([
  4
  8
  16
  32
  40
  64
  80
])
param vCores int

@description('Optional. For Azure Hybrid Benefit, use BasePrice.')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string = 'LicenseIncluded'

@allowed([
  'local'
  'zone'
  'geo'
])
@description('Optional. Set location of backups, geo, local or zone.')
param requestedBackupStorageRedundancy string = 'geo'

@description('Optional. Specifies the mode of database creation.')
@allowed([
  'Default'
  'PointInTimeRestore'
])
param managedInstanceCreateMode string = 'Default'

@description('Optional. Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database.')
param restorePointInTime string = ''

@description('Optional. The resource identifier of the source managed instance associated with create operation of this instance.')
param sourceManagedInstanceId string = ''

@description('Optional. The Managed Instance Collation.')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Optional. Whether or not the public data endpoint is enabled.')
param publicDataEndpointEnabled bool = false

@description('Optional. Storage size in GB. Minimum value: 32. Increments of 32 GB allowed only.')
param storageSizeInGB int

@description('Optional. Subnet resource ID for the managed instance.')
param subnetId string

@description('Optional. Whether or not the multi-az is enabled.')
param zoneRedundant bool = false

@description('Optional. The server connection type. Note private link requires Proxy.')
@allowed([
  'Default'
  'Proxy'
  'Redirect'
])
param proxyOverride string = 'Default'

@description('Optional. The resource id of another managed instance whose DNS zone this managed instance will share after creation.')
param dnsZonePartner string = ''

@description('Optional. The Id of the instance pool this managed server belongs to.')
param instancePoolId string = ''

@description('Optional. The managed instance service principal. (None or SystemAssigned)')
@allowed([
  'None'
  'SystemAssigned'
])
param servicePrincipalType string = 'None'

@description('Optional. The Id of the TimeZone. (eg: "AUS Eastern Standard Time")')
param timezoneId string = 'UTC'

@description('Optional. Enable Vulnerability Assessments. Not currently supported with user managed identities.')
param enableVulnerabilityAssessments bool = true

@description('Optional. Resource ID of the Storage Account to store Vulnerability Assessments. Required when enableVulnerabilityAssessments set to "true". ')
param vulnerabilityAssessmentStorageId string = ''

@description('Optional. Specifies that the schedule scan notification will be is sent to the subscription administrators.')
param emailAccountAdmins bool = false

@description('Optional. Specifies an array of e-mail addresses to which the scan notification is sent.')
param emailAddresses array = []

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
  'Audit'
  'AllLogs'
])
param diagnosticLogCategoriesToEnable array = [
  'AllLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
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
param resourcelock string = 'CanNotDelete'

var vulnerabilityAssessmentStorageResourceGroup = enableVulnerabilityAssessments ? split(vulnerabilityAssessmentStorageId, '/')[4] : 'placeholder' // must contain placeholder value as it is evaulated as part of the scope of the role assignment module

var vulnerabilityAssessmentStorageSubId = enableVulnerabilityAssessments ? split(vulnerabilityAssessmentStorageId, '/')[2] : 'placeholder' // must contain placeholder value as it is evaulated as part of the scope of the role assignment module

var vulnerabilityAssessmentStorageName = enableVulnerabilityAssessments ? last(split(vulnerabilityAssessmentStorageId, '/')) : null

var lockName = toLower('${managedInstance.name}-${resourcelock}-lck')

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var diagnosticsName = toLower('${managedInstance.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoriesToEnable: {
  categoryGroup: categoryGroup
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

resource vulnerabilityAssessmentStorage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if (enableVulnerabilityAssessments) {
  scope: resourceGroup(vulnerabilityAssessmentStorageSubId, vulnerabilityAssessmentStorageResourceGroup)
  name: vulnerabilityAssessmentStorageName
}

module vulnerabilityAssessmentRoleAssignment 'roleAssignment.bicep' = if (enableVulnerabilityAssessments && !empty(identity)) {
  scope: resourceGroup(vulnerabilityAssessmentStorageSubId, vulnerabilityAssessmentStorageResourceGroup)
  name: 'vulnerabilityAssessmentRoleAssignment'
  params: {
    storageAccountName: vulnerabilityAssessmentStorageName
    principalId: managedInstance.identity.principalId
  }
}

resource managedInstance 'Microsoft.Sql/managedInstances@2022-05-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  identity: identity
  properties: {
    administratorLogin: !empty(administratorLogin) ? administratorLogin : null
    administratorLoginPassword: !empty(administratorLoginPassword) ? administratorLoginPassword : null
    administrators: !empty(administrators) ? {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: administrators.azureADOnlyAuthentication
      login: administrators.login
      principalType: administrators.principalType
      sid: administrators.sid
      tenantId: contains(administrators, 'tenantId') ? administrators.tenantId : subscription().tenantId
    } : {}

    collation: collation
    dnsZonePartner: !empty(dnsZonePartner) ? dnsZonePartner : null
    instancePoolId: !empty(instancePoolId) ? instancePoolId : null
    licenseType: licenseType
    managedInstanceCreateMode: managedInstanceCreateMode
    minimalTlsVersion: '1.2'
    primaryUserAssignedIdentityId: primaryUserAssignedIdentityId
    proxyOverride: proxyOverride
    publicDataEndpointEnabled: publicDataEndpointEnabled
    restorePointInTime: !empty(restorePointInTime) ? restorePointInTime : null
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
    servicePrincipal: {
      type: servicePrincipalType
    }
    sourceManagedInstanceId: !empty(sourceManagedInstanceId) ? sourceManagedInstanceId : null
    storageSizeInGB: storageSizeInGB
    subnetId: subnetId
    timezoneId: timezoneId
    vCores: vCores
    zoneRedundant: zoneRedundant

  }
}

resource securityThreatAlertPolicies 'Microsoft.Sql/managedInstances/securityAlertPolicies@2021-11-01' = {
  parent: managedInstance
  name: 'default'
  properties: {
    state: 'Enabled'
    emailAccountAdmins: emailAccountAdmins
    emailAddresses: emailAddresses
    retentionDays: threatDetectionRetentionDays
  }
}

resource vulnerabilityAssessments 'Microsoft.Sql/managedInstances/vulnerabilityAssessments@2021-11-01' = if (enableVulnerabilityAssessments) {
  parent: managedInstance
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

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: managedInstance
  name: diagnosticsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticLogAnalyticsWorkspaceId) ? diagnosticLogAnalyticsWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: managedInstance
  name: lockName
  properties: {
    level: resourcelock
    notes: resourcelock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the managed instance.')
output name string = managedInstance.name

@description('The resource ID of the managed instance.')
output resourceId string = managedInstance.id
