/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/
param location string = 'australiaeast'

@secure()
param psqlPassword string = uniqueString(newGuid())

module postgres '../main.bicep' = {
  name: 'deploy_postgres'
  params: {
    location: location
    name: 'testpostgres'
    administratorLogin: 'psqladmin'
    administratorLoginPassword: psqlPassword
    backupRetentionDays: 30
    skuName: 'Standard_D4s_v3'
    skuTier: 'GeneralPurpose'
    storageSizeGB: 64
    version: '13'
  }
}
