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

@description('Defender for Cloud default values.')
param defenderPlansMax array = [
  {
    name: 'CloudPosture'
    pricingTier: 'Standard'
  }
  {
    name: 'VirtualMachines'
    pricingTier: 'Standard'
  }
  {
    name: 'SqlServers'
    pricingTier: 'Standard'
  }
  {
    name: 'SqlServerVirtualMachines'
    pricingTier: 'Standard'
  }
  {
    name: 'OpenSourceRelationalDatabases'
    pricingTier: 'Standard'
  }
  {
    name: 'AppServices'
    pricingTier: 'Standard'
  }
  {
    name: 'StorageAccounts'
    pricingTier: 'Standard'
    subPlan: 'DefenderForStorageV2'
  }
  {
    name: 'Containers'
    pricingTier: 'Standard'
  }
  {
    name: 'KeyVaults'
    pricingTier: 'Standard'
  }
  {
    name: 'Arm'
    pricingTier: 'Standard'
  }
  {
    name: 'CosmosDbs'
    pricingTier: 'Standard'
  }
  {
    name: 'Api'
    pricingTier: 'Standard'
  }
]

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
    workspaceScope: subscription().subscriptionId
    notificationsByRole: [
      'Owner'
      'ServiceAdmin'
    ]
    phone: '+61412567890'
    defenderPlans: defenderPlansMax
  }
}
