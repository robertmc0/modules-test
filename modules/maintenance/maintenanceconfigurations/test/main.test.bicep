/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

/*======================================================================
TEST EXECUTION
======================================================================*/
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
    windowsClassificationsToInclude: [
      'Critical'
      'Security'
    ]
    linuxClassificationsToInclude: [
      'Critical'
      'Security'
    ]
  }
}
