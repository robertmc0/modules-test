/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

/*======================================================================
TEST EXECUTION
======================================================================*/
module maintenanceConfigurationMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-maintenance-configuration'
  params: {
    name: '${uniqueString(deployment().name, location)}-min-mcfg'
    location: location
    maintenanceWindow: {
      startDateTime: '2022-12-28 03:00'
      duration: '02:00'
      timeZone: 'AUS Eastern Standard Time'
      recurEvery: '1Month Fourth Wednesday'
    }
    windowsClassificationsToInclude: [
      'Critical'
      'Security'
    ]
  }
}

module maintenanceConfiguration '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-maintenance-configuration'
  params: {
    name: '${uniqueString(deployment().name, location)}-mcfg'
    location: location
    maintenanceWindow: {
      startDateTime: '2022-12-28 03:00'
      duration: '02:00'
      timeZone: 'AUS Eastern Standard Time'
      recurEvery: '1Month Fourth Wednesday'
    }
    rebootSetting: 'IfRequired'
    inGuestPatchMode: 'User'
    maintenanceScope: 'InGuestPatch'
    visibility: 'Custom'
    resourceLock: 'NotSpecified'
    windowsClassificationsToInclude: [
      'Critical'
      'Security'
      'UpdateRollup'
      'FeaturePack'
      'ServicePack'
      'Definition'
      'Tools'
      'Updates'
    ]
    linuxClassificationsToInclude: [
      'Critical'
      'Security'
      'Other'
    ]
  }
}

module maintenanceConfigurationPatchExclusions '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-maintenance-configuration'
  params: {
    name: '${uniqueString(deployment().name, location)}-mcfg'
    location: location
    maintenanceWindow: {
      startDateTime: '2022-12-28 03:00'
      duration: '02:00'
      timeZone: 'AUS Eastern Standard Time'
      recurEvery: '1Month Fourth Wednesday'
    }
    rebootSetting: 'IfRequired'
    inGuestPatchMode: 'User'
    maintenanceScope: 'InGuestPatch'
    visibility: 'Custom'
    resourceLock: 'NotSpecified'
    windowsClassificationsToInclude: [
      'Critical'
      'Security'
      'UpdateRollup'
      'FeaturePack'
      'ServicePack'
      'Definition'
      'Tools'
      'Updates'
    ]
    windowsKbNumbersToExclude: [
      'KB5034439'
    ]
    linuxClassificationsToInclude: [
      'Critical'
      'Security'
      'Other'
    ]
    linuxPackageNameMasksToExclude: [
      'openjdk-*'
    ]
  }
}
