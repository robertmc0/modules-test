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

@description('Optional. The default pricing tier for Cloud Security Posture Management (CSPM) plan.')
@allowed([
  'Standard'
  'Free'
])
param pricingCloudPosture string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for Servers.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierVMs string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for SQL.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierSqlServers string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for App Service.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierAppServices string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for Storage.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierStorageAccounts string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for SQL VMs.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierSqlServerVirtualMachines string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for Open Source Relational Databases.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierOpenSourceRelationalDatabases string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for Containers.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierContainers string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for Key Vaults.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierKeyVaults string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for DNS.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierDns string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for ARM.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierArm string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for CosmosDbs.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierCosmosDbs string = 'Free'

@description('Optional. The pricing tier for Microsoft Defender for APIs.')
@allowed([
  'Standard'
  'Free'
])
param pricingTierApis string = 'Free'

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

resource cloudPosture 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'CloudPosture'
  properties: {
    pricingTier: pricingCloudPosture
  }
}

resource virtualMachines 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'VirtualMachines'
  properties: {
    pricingTier: pricingTierVMs
  }
}

resource sqlServers 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'SqlServers'
  properties: {
    pricingTier: pricingTierSqlServers
  }
}

resource sqlServerVirtualMachines 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'SqlServerVirtualMachines'
  properties: {
    pricingTier: pricingTierSqlServerVirtualMachines
  }
}

resource openSourceRelationalDatabases 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'OpenSourceRelationalDatabases'
  properties: {
    pricingTier: pricingTierOpenSourceRelationalDatabases
  }
}

resource appServices 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'AppServices'
  properties: {
    pricingTier: pricingTierAppServices
  }
}

resource storageAccounts 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: pricingTierStorageAccounts
  }
}

resource containers 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'Containers'
  properties: {
    pricingTier: pricingTierContainers
  }
}

resource keyVaults 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'KeyVaults'
  properties: {
    pricingTier: pricingTierKeyVaults
  }
}

resource dns 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'Dns'
  properties: {
    pricingTier: pricingTierDns
  }
}

resource arm 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'Arm'
  properties: {
    pricingTier: pricingTierArm
  }
}

resource cosmos 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'CosmosDbs'
  properties: {
    pricingTier: pricingTierCosmosDbs
  }
}

resource api 'Microsoft.Security/pricings@2022-03-01' = {
  name: 'Api'
  properties: {
    pricingTier: pricingTierApis
  }
}

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
