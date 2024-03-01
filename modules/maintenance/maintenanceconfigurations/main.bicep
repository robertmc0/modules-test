metadata name = 'Maintenance Configuration module'
metadata description = 'This module deploys Microsoft.Maintenance maintenanceConfigurations'
metadata owner = 'Arinco'

@description('Maintenance Configuration Name.')
param name string

@description('Optional. Specifies the mode of in-guest patching to IaaS virtual machine.')
@allowed([
  'User'
  'Platform'
])
param inGuestPatchMode string = 'User'

@description('Optional. Choose classification of patches to include in Linux patching.')
@allowed([
  'Critical'
  'Security'
  'Other'
])
param linuxClassificationsToInclude array = []

@description('Location for all Resources.')
param location string

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

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. Gets or sets the visibility of the configuration. The default value is \'Custom\'.')
@allowed([
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

@description('Optional. Choose patch KB to exclude from Windows patching.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#inputwindowsparameters'
  example: {
    tagKey: [ 'KB5034439' ]
  }
})
param windowsKbNumbersToExclude array = []

@description('Optional. Choose packages to exclude from linux updates.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#inputwindowsparameters'
  example: {
    tagKey: [ 'openjdk-*' ]
  }
})
param linuxPackageNameMasksToExclude array = []

var lockName = toLower('${maintenanceConfiguration.name}-${resourceLock}-lck')

resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    extensionProperties: {
      InGuestPatchMode: inGuestPatchMode
    }
    maintenanceScope: maintenanceScope
    maintenanceWindow: maintenanceWindow
    visibility: visibility
    installPatches: {
      rebootSetting: rebootSetting
      windowsParameters: {
        classificationsToInclude: !empty(windowsClassificationsToInclude) ? windowsClassificationsToInclude : null
        kbNumbersToExclude: !empty(windowsKbNumbersToExclude) ? windowsKbNumbersToExclude : null
      }
      linuxParameters: {
        classificationsToInclude: !empty(linuxClassificationsToInclude) ? linuxClassificationsToInclude : null
        packageNameMasksToExclude: !empty(linuxPackageNameMasksToExclude) ? linuxPackageNameMasksToExclude : null
      }
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: maintenanceConfiguration
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the Maintenance Configuration.')
output name string = maintenanceConfiguration.name

@description('The resource ID of the Maintenance Configuration.')
output resourceId string = maintenanceConfiguration.id
