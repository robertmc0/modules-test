param location string = resourceGroup().location

module names '../../../naming/conventions/main.bicep' = {
  scope: subscription()
  name: '${uniqueString(deployment().name, location)}-names'
  params: {
    location: location
    prefixes: [
      'ar'
      '**location**'
      'tst'
    ]
    suffixes: [
      'adr'
    ]
  }
}

module appConfiguration '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-appc'
  params: {
    name: names.outputs.names.appConfig.name
    location: location
  }
}
