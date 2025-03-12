param location string = resourceGroup().location

@allowed([
  'Free'
  'Standard'
])
@description('Optional. Name of the Static Web App SKU used for API Center Portal.')
param apiCenterPortalStaticWebAppSku string = 'Free'

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

module staticWebApp '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-stapp'
  params: {
    location: location
    name: names.outputs.names.staticWebAppName.name
    sku: apiCenterPortalStaticWebAppSku
  }
}
