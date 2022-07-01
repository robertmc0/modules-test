// Module to deploy postgreSQL flsxible servers

@description('Required. Name of your Azure PostgreSQL Flexible Server')
@minLength(5)
@maxLength(50)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3.')
param skuName string

@description('The tier of the particular SKU, e.g. Burstable.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string

@description('The administrators login name of a server. Can only be specified when the server is being created (and is required for creation).')
param administratorLogin string

@description('The administrator login password (required for server creation).')
@secure()
param administratorLoginPassword string

@description('Backup retention days for the server.')
param backupRetentionDays int

@description('A value indicating whether Geo-Redundant backup is enabled on the server.')
@allowed([
  'Disabled'
  'Enabled'
])
param geoRedundantBackup string = 'Disabled'

@description('The mode to create a new PostgreSQL server.')
@allowed([
  'Create'
  'Default'
  'PointInTimeRestore'
  'Update'
])
param createMode string = 'Create'

@description('The HA mode for the server.')
@allowed([
  'Disabled'
  'ZoneRedundant'
])
param highAvailabilityMode string = 'Disabled'

@description('availability zone information of the standby.')
param standbyAvailabilityZone string = ''

@description('indicates whether custom window is enabled or disabled.')
@allowed([
  'disabled'
  'enabled'
])
param customWindow string = 'disabled'

@description('day of week for maintenance window')
param dayOfWeek int = 0

@description('start hour for maintenance window')
param startHour int = 0

@description('start minute for maintenance window')
param startMinute int = 0

@description('Max storage allowed for a server.')
param storageSizeGB int

@description('The version of a server.')
@allowed([
  '11'
  '12'
  '13'
])
param version string

resource symbolicname 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    createMode: createMode
    highAvailability: {
      mode: highAvailabilityMode
      standbyAvailabilityZone: standbyAvailabilityZone
    }
    maintenanceWindow: {
      customWindow: customWindow
      dayOfWeek: dayOfWeek
      startHour: startHour
      startMinute: startMinute
    }
    // network: {
    //   delegatedSubnetResourceId: 'string'
    //   privateDnsZoneArmResourceId: 'string'
    // }
    storage: {
      storageSizeGB: storageSizeGB
    }
    version: version
  }
}
