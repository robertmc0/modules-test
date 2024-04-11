metadata name = 'Azure Firewall Policy Module'
metadata description = 'This module deploys Microsoft.Network firewallPolicies'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Tier of the Azure Firewall Policy.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param tier string

@description('Optional. The operation mode for Threat Intelligence.')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param threatIntelMode string = 'Alert'

@description('Optional. Threat Intelligence Allowlist.')
@metadata({
  example: {
    ipAddresses: ['10.0.1.6']
    fqdns: ['contoso.com']
  }
})
param threatIntelAllowlist object = {}

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Enable DNS Proxy on Firewalls attached to the Firewall Policy.')
param enableDnsProxy bool = false

@description('Optional. List of Custom DNS Servers. Only required when enableDnsProxy set to true.')
param customDnsServers array = []

@description('Assembles the DNS settings for the Firewall Policy based off the defined Tier.')
var dnsProperties = tier == 'Basic'
  ? null
  : tier != 'Basic'
      ? {
          enableProxy: enableDnsProxy
          servers: customDnsServers
        }
      : null

@description('Optional. Intrusion Detection Configuration. Requires Premium SKU.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies?pivots=deployment-language-bicep#firewallpolicyintrusiondetection'
  example: {
    mode: 'Deny'
    configuration: {
      privateRanges: [
        '152.0.0.0/16'
      ]
      signatureOverrides: [
        {
          id: '2024898'
          mode: 'Deny'
        }
        {
          id: '2024897'
          mode: 'Alert'
        }
      ]
      bypassTrafficSettings: [
        {
          name: 'Application 1'
          description: 'Bypass traffic for Application #1'
          sourceAddresses: ['*']
          destinationAddresses: ['10.0.1.6']
          destinationPorts: ['443']
          protocol: 'TCP'
        }
      ]
    }
  }
})
param intrusionDetection object = {}

@description('Optional. TLS Configuration definition. Requires Premium SKU.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.network/firewallpolicies?pivots=deployment-language-bicep#firewallpolicytransportsecurity'
  example: {
    certificateAuthority: {
      name: 'contosoCASecretName'
      #disable-next-line no-hardcoded-env-urls
      keyVaultSecretId: 'https://contoso-kv.vault.azure.net/secrets/contosoCASecretName'
    }
  }
})
param transportSecurity object = {}

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${firewallPolicy.name}-${resourceLock}-lck')

var identityType = systemAssignedIdentity
  ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
  : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None'
  ? {
      type: identityType
      userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
    }
  : null

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    dnsSettings: dnsProperties
    sku: {
      tier: tier
    }
    threatIntelMode: threatIntelMode
    threatIntelWhitelist: threatIntelAllowlist
    intrusionDetection: !empty(intrusionDetection) ? intrusionDetection : null
    transportSecurity: !empty(transportSecurity) ? transportSecurity : null
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' =
  if (resourceLock != 'NotSpecified') {
    scope: firewallPolicy
    name: lockName
    properties: {
      level: resourceLock
      notes: (resourceLock == 'CanNotDelete')
        ? 'Cannot delete resource or child resources.'
        : 'Cannot modify the resource or child resources.'
    }
  }

@description('The name of the deployed Azure firewall policy.')
output name string = firewallPolicy.name

@description('The resource ID of the deployed Azure firewall policy.')
output resourceId string = firewallPolicy.id
