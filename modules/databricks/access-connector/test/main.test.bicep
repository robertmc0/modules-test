param location string = resourceGroup().location

param tags object = {
  environment: 'shared services'
  application: 'data platform'
}

param resourceLock string = 'CanNotDelete'

module connector '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-adb-ac'
  params: {
    name: '${uniqueString(deployment().name, location)}-adb-ac'
    location: location
    tags: tags
    resourceLock: resourceLock
  }
}
