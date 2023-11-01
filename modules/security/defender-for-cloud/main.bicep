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
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'VirtualMachines'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'SqlServers'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'SqlServerVirtualMachines'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'OpenSourceRelationalDatabases'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'AppServices'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'StorageAccounts'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'Containers'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'KeyVaults'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'Dns'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'Arm'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'CosmosDbs'
      pricingTier: '[Standard/Free]'
    }
    {
      name: 'Api'
      pricingTier: '[Standard/Free]'
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
    name: 'Dns'
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
