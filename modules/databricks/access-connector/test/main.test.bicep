param name string = 'adb-ac-dataplatform'

param location string = resourceGroup().location

param tags object = {
  environment: 'shared services'
  application: 'data platform'
}

param resourceLock string = 'CanNotDelete'

module connector '../main.bicep' = {
  name: 'adb-access-connector-${uniqueString(deployment().name, location)}'
  params: {
    name: name
    location: location
    tags: tags
    resourceLock: resourceLock
  }
}
