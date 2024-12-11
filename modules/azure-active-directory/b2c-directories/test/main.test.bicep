param location string = resourceGroup().location

param b2cLocation string = 'australia'

// Currently not using naming module
// as Tenants use a given name
var uniqueName = uniqueString(deployment().name, location)

module b2cTenant '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-b2c'
  params: {
    location: b2cLocation
    tenantName: uniqueName
    displayName: uniqueName
    countryCode: 'AU'
  }
}
