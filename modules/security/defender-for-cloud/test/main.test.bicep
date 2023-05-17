/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'subscription'

@description('Optional. The geo-location where the resource lives.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${shortIdentifier}-tst-rg-${uniqueString(deployment().name, 'resourceGroup', location)}'
  location: location
}

module logAnalyticsWorkspace 'main.test.prereqs.bicep' = {
  scope: az.resourceGroup(resourceGroup.name)
  name: '${uniqueString(deployment().name, location)}-law'
  params: {
    name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
    location: location
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module defenderMinimum '../main.bicep' = {
  scope: subscription((subscription().subscriptionId))
  name: '${uniqueString(deployment().name, location)}-min-defend'
  params: {
    workspaceId: logAnalyticsWorkspace.outputs.resourceId
    emailAddress: 'john.smith@contoso.com.au'
    alertNotificationSeverity: 'High'
  }
}

module defender '../main.bicep' = {
  dependsOn: [
    defenderMinimum
  ]
  scope: subscription((subscription().subscriptionId))
  name: '${uniqueString(deployment().name, location)}-defend'
  params: {
    workspaceId: logAnalyticsWorkspace.outputs.resourceId
    emailAddress: 'john.smith@contoso.com.au'
    alertNotificationSeverity: 'High'
    autoProvision: 'On'
    notificationsByRole: [
      'Owner'
      'ServiceAdmin'
    ]
    phone: '+61412567890'
    pricingCloudPosture: 'Standard'
    pricingTierAppServices: 'Standard'
    pricingTierArm: 'Standard'
    pricingTierContainers: 'Standard'
    pricingTierCosmosDbs: 'Standard'
    pricingTierDns: 'Standard'
    pricingTierKeyVaults: 'Standard'
    pricingTierOpenSourceRelationalDatabases: 'Standard'
    pricingTierSqlServers: 'Standard'
    pricingTierSqlServerVirtualMachines: 'Standard'
    pricingTierStorageAccounts: 'Standard'
    pricingTierVMs: 'Standard'
    pricingTierApi: 'Standard'
  }
}
