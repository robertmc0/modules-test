@description('Required. Maintenance Configuration Name.')
param name string

@description('Optional. Choose classification of patches to include in Linux patching.')
@allowed([
  'Critical'
  'Security'
  'Other'
])
param linuxClassificationsToInclude array = []

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Specify the type of lock.')
@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
param lock string = ''

@description('Optional. Gets or sets maintenanceScope of the configuration.')
@allowed([
  'Host'
  'OSImage'
  'Extension'
  'InGuestPatch'
  'SQLDB'
  'SQLManagedInstance'
])
param maintenanceScope string = 'InGuestPatch'

@description('Optional. Definition of a MaintenanceWindow.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#maintenancewindow'
  example: {
    duration: 'string'
    expirationDateTime: 'string'
    recurEvery: 'string'
    startDateTime: 'string'
    timeZone: 'string'
  }
})
param maintenanceWindow object = {}

@description('Optional. Sets the reboot setting for the patches.')
@allowed([
  'Always'
  'IfRequired'
  'Never'
])
param rebootSetting string = 'IfRequired'

@description('Optional. Gets or sets tags of the resource.')
param tags object = {}

@description('Optional. Gets or sets the visibility of the configuration. The default value is \'Custom\'.')
@allowed([
  ''
  'Custom'
  'Public'
])
param visibility string = 'Custom'

@description('Optional. Choose classification of patches to include in Windows patching.')
@allowed([
  'Critical'
  'Security'
  'UpdateRollup'
  'FeaturePack'
  'ServicePack'
  'Definition'
  'Tools'
  'Updates'
])
param windowsClassificationsToInclude array = []

resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2022-11-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    extensionProperties: {
      inGuestPatchMode: 'User'
    }
    maintenanceScope: maintenanceScope
    maintenanceWindow: maintenanceWindow
    visibility: visibility
    installPatches: {
      rebootSetting: rebootSetting
      windowsParameters: {
        classificationsToInclude: windowsClassificationsToInclude
      }
      linuxParameters: {
        classificationsToInclude: linuxClassificationsToInclude
      }
    }
  }
}

resource maintenanceConfiguration_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock)) {
  name: '${maintenanceConfiguration.name}-${lock}-lock'
  properties: {
    level: any(lock)
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: maintenanceConfiguration
}

@description('The name of the Maintenance Configuration.')
output name string = maintenanceConfiguration.name

@description('The resource ID of the Maintenance Configuration.')
output resourceId string = maintenanceConfiguration.id
