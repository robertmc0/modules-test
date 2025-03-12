metadata name = 'Entra B2C Module'
metadata description = 'This module deploys an Entra B2C (Microsoft.AzureActiveDirectory/b2cDirectories) resource.'
metadata owner = 'Arinco'

@description('Name of the B2C Tenant')
@minLength(3)
@maxLength(37)
param tenantName string

@description('The display name for the Entra B2C Directory.')
param displayName string

@description('The location where the Entra B2C Directory will be deployed.')
@allowed([
  'global'
  'unitedstates'
  'europe'
  'asiapacific'
  'australia'
  'japan'
])
param location string

@description('Optional. The name of the SKU for the Entra B2C Directory.')
@allowed([
  'PremiumP1'
  'PremiumP2'
  'Standard'
])
param skuName string = 'Standard'

@description('Optional. The tier of the SKU for the Entra B2C Directory.')
param skuTier string = 'A0'

@description('The country code for the tenant. See https://learn.microsoft.com/en-us/azure/active-directory-b2c/data-residency for more details.')
@allowed([
  'AF'
  'AE'
  'AT'
  'AU'
  'AZ'
  'BE'
  'BG'
  'BH'
  'BY'
  'CA'
  'CH'
  'CR'
  'CY'
  'CZ'
  'DE'
  'DK'
  'DO'
  'DZ'
  'EE'
  'EG'
  'ES'
  'FI'
  'FR'
  'GB'
  'GR'
  'GT'
  'HK'
  'HR'
  'HU'
  'ID'
  'IE'
  'IL'
  'IN'
  'IS'
  'IT'
  'JO'
  'JP'
  'KE'
  'KR'
  'KW'
  'KZ'
  'LB'
  'LI'
  'LK'
  'LT'
  'LU'
  'LV'
  'MA'
  'ME'
  'ML'
  'MT'
  'MX'
  'MY'
  'NG'
  'NL'
  'NO'
  'NZ'
  'OM'
  'PA'
  'PH'
  'PK'
  'PL'
  'PR'
  'PT'
  'QA'
  'RO'
  'RS'
  'RU'
  'SA'
  'SE'
  'SG'
  'SK'
  'ST'
  'SV'
  'TN'
  'TR'
  'TT'
  'TW'
  'UA'
  'US'
  'ZA'
])
param countryCode string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

var directoryName = toLower('${tenantName}.onmicrosoft.com')

resource entraB2C 'Microsoft.AzureActiveDirectory/b2cDirectories@2021-04-01' = {
  name: directoryName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    createTenantProperties: {
      countryCode: countryCode
      displayName: displayName
    }
  }
}

@description('The resource ID of the created Entra B2C Tenant.')
output directoryId string = entraB2C.id

@description('The location of the created Entra B2C Tenant.')
output directoryLocation string = entraB2C.location

@description('The tenant ID of the created Entra B2C Tenant.')
output tenantId string = entraB2C.properties.tenantId
