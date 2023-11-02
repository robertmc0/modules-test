metadata name = 'Defender for Cloud Module'
metadata description = 'This module deploys Microsoft Defender for Cloud plans, contacts and configuration settings.'
metadata owner = 'Arinco'

targetScope = 'subscription'

@description('Email address which will get notifications from Microsoft Defender for Cloud by the configurations defined in this security contact.')
param emailAddress string

@description('Optional. The security contact\'s phone number.')
param phone string = ''

@description('Defines the minimal alert severity which will be sent as email notifications.')
@allowed([
  'High'
  'Medium'
  'Low'
])
param alertNotificationSeverity string

@description('Optional. Defines which RBAC roles will get email notifications from Microsoft Defender for Cloud.')
@allowed([
  'AccountAdmin'
  'Contributor'
  'Owner'
  'ServiceAdmin'
])
param notificationsByRole array = []

@description('Optional. The plans Microsoft Defender for Cloud.')
@metadata({
  defenderPlans: [
    {
      name: 'CloudPosture'
      pricingTier: 'The pricing tier of the Defender CSPM plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'VirtualMachines'
      pricingTier: 'The pricing tier of the Defender VirtualMachines plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'SqlServers'
      pricingTier: 'The pricing tier of the Defender SqlServers plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'SqlServerVirtualMachines'
      pricingTier: 'The pricing tier of the Defender SqlServerVirtualMachines plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'OpenSourceRelationalDatabases'
      pricingTier: 'The pricing tier of the Defender OpenSourceRelationalDatabases plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'AppServices'
      pricingTier: 'The pricing tier of the Defender AppServices plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'StorageAccounts'
      pricingTier: 'The pricing tier of the Defender StorageAccounts plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'Containers'
      pricingTier: 'The pricing tier of the Defender Containers plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'KeyVaults'
      pricingTier: 'The pricing tier of the Defender KeyVaults plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'Arm'
      pricingTier: 'The pricing tier of the Defender Arm plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'CosmosDbs'
      pricingTier: 'The pricing tier of the Defender CosmosDbs plan. Allowed values "Standard" or "Free".'
    }
    {
      name: 'Api'
      pricingTier: 'The pricing tier of the Defender Api plan. Allowed values "Standard" or "Free".'
    }
  ]
})
param defenderPlans array = [
  {
    name: 'CloudPosture'
    pricingTier: 'Free'
  }
  {
    name: 'VirtualMachines'
    pricingTier: 'Free'
  }
  {
    name: 'SqlServers'
    pricingTier: 'Free'
  }
  {
    name: 'SqlServerVirtualMachines'
    pricingTier: 'Free'
  }
  {
    name: 'OpenSourceRelationalDatabases'
    pricingTier: 'Free'
  }
  {
    name: 'AppServices'
    pricingTier: 'Free'
  }
  {
    name: 'StorageAccounts'
    pricingTier: 'Free'
  }
  {
    name: 'Containers'
    pricingTier: 'Free'
  }
  {
    name: 'KeyVaults'
    pricingTier: 'Free'
  }
  {
    name: 'Arm'
    pricingTier: 'Free'
  }
  {
    name: 'CosmosDbs'
    pricingTier: 'Free'
  }
  {
    name: 'Api'
    pricingTier: 'Free'
  }
]

@description('Resource ID of the Log Analytics workspace.')
param workspaceId string

@description('Optional. All the VMs in this scope will send their security data to the mentioned workspace unless overridden by a setting with more specific scope.')
param workspaceScope string = subscription().subscriptionId

@description('Optional. Automatically enable new resources into the log analytics workspace.')
@allowed([
  'On'
  'Off'
])
param autoProvision string = 'On'

var defaultPricingTier = 'Free'

resource securityContacts 'Microsoft.Security/securityContacts@2020-01-01-preview' = {
  name: 'default'
  properties: {
    emails: emailAddress
    phone: !empty(phone) ? phone : null
    notificationsByRole: !empty(notificationsByRole) ? {
      roles: notificationsByRole
      state: 'On'
    } : {}
    alertNotifications: {
      minimalSeverity: alertNotificationSeverity
      state: 'On'
    }
  }
}

@batchSize(1)
resource defenderPlan 'Microsoft.Security/pricings@2023-01-01' = [for plan in defenderPlans: {
  name: plan.name
  properties: {
    pricingTier: !empty(plan.pricingTier) ? plan.pricingTier : defaultPricingTier
  }
}]

resource workspace 'Microsoft.Security/workspaceSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    scope: '/subscriptions/${workspaceScope}'
    workspaceId: workspaceId
  }
}

resource autoProvisioningSettings 'Microsoft.Security/autoProvisioningSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    autoProvision: autoProvision
  }
}
