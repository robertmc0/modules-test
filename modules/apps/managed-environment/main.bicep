metadata name = 'Container Apps Managed environment'
metadata description = 'This module deploys Microsoft App Managed Environments'
metadata owner = 'Arinco'

@description('The resource name.')
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

@description('Optional. Enable mutual TLS.')
param mtlsEnabled bool = false

@description('Optional. Enable peer traffic encryption.')
param peerEncryptionEnabled bool = false

@description('Optional. Enable zone redundancy.')
param isZoneRedundant bool = false

@description('Optional. Name of the Application Insights resource.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep#vnetconfiguration'
  example: {
    infrastructureSubnetId: 'string'
    internal : 'bool'
    platformReservedCidr: 'string'
    platformReservedDnsIP: 'string'
    dockerBridgeCidr: 'string'
  }
})
param vnetConfiguration object = {}

@description('Optional. Application Insights resource for DAPR logs.')
@metadata({
  example: {
    ConnectionString: 'string'
    InstrumentationKey : 'string'
  }
})
param applicationInsights object = {}

@description('Optional. Log analytics resource for DAPR logs.')
@metadata({
  example: {
    customerId: 'string'
    sharedKey: 'string'
  }
})
param logAnalyticsConfiguration object = {}

@description('Optional. Allow or block all public traffic. ')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. Name of the platform-managed resource group created for the Managed Environment to host infrastructure resources.If a subnet ID is provided, this resource group will be created in the same subscription as the subnet.')
param infrastructureResourceGroup string = ''

@description('Optional. DNS suffix for the environment domain.')
param dnsSuffix string = ''

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${containerAppsEnvironment.name}-${resourceLock}-lck')

#disable-next-line BCP081
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: logAnalyticsConfiguration
    }   
    daprAIConnectionString: applicationInsights.ConnectionString
    daprAIInstrumentationKey: applicationInsights.InstrumentationKey
    infrastructureResourceGroup: infrastructureResourceGroup
    publicNetworkAccess: publicNetworkAccess
    vnetConfiguration: vnetConfiguration
    customDomainConfiguration: {
      dnsSuffix: dnsSuffix
    }
    peerAuthentication:{
      mtls: {
        enabled: mtlsEnabled
      }
    }
    peerTrafficConfiguration:{
      encryption:{
        enabled: peerEncryptionEnabled
      }
    }
    zoneRedundant: isZoneRedundant
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: containerAppsEnvironment
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('Name of the the deployed managed environment.')
output managedEnvironmentName string = containerAppsEnvironment.name

@description('The resource ID of the deployed managed environment.')
output managedEnvironmentId string = containerAppsEnvironment.id