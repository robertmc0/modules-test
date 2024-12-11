param location string = resourceGroup().location

module apiCenter '../../../api-center/services/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-appc-01'
  params: {
    name: '${uniqueString(deployment().name, location)}-appc-01'
    location: location
  }
}
