/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'ari'

@description('Optional. Resource tags.')
param tags object = {
  environment: 'test'
}

/*======================================================================
TEST PREREQUISITES
======================================================================*/
// Azure RBAC is not currently supported for key vault integration with Azure Firewall Policy, refer to: https://learn.microsoft.com/en-us/azure/firewall/premium-certificates#azure-key-vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${shortIdentifier}-tst-k5-${uniqueString(deployment().name, 'kv', location)}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: userIdentity.properties.principalId
        permissions: {
          certificates: [
            'get'
            'list'
            'create'
            'import'
            'listissuers'
          ]
          secrets: [
            'get'
            'list'
          ]
        }
        tenantId: tenant().tenantId
      }
    ]
    enableRbacAuthorization: false
    enabledForTemplateDeployment: true
    networkAcls: {
      bypass: 'AzureServices'
    }
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${shortIdentifier}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
  location: location
}

module createFirewallCACert 'main.test.prereqs.bicep' = {
  name: '${shortIdentifier}-tst-cacert-${uniqueString(deployment().name, 'createCACert', location)}'
  params: {
    location: location
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    keyVaultName: keyVault.name
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module firewallPolicyBasic '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-firewall-pol'
  params: {
    name: '${shortIdentifier}-tst-bsc-fwl-pol-${uniqueString(deployment().name, 'azureFirewallPolicy', location)}'
    location: location
    tier: 'Basic'
  }
}

module firewallPolicyStandard '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-firewall-pol'
  params: {
    name: '${shortIdentifier}-tst-std-fwl-pol-${uniqueString(deployment().name, 'azureFirewallPolicy', location)}'
    location: location
    tier: 'Standard'
  }
}

module firewallPolicy '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-firewall-pol'
  params: {
    name: '${shortIdentifier}-tst-fwl-pol-${uniqueString(deployment().name, 'azureFirewallPolicy', location)}'
    tags: tags
    location: location
    tier: 'Premium'
    enableDnsProxy: true
    customDnsServers: [
      '10.0.1.5'
      '10.0.1.6'
    ]
    threatIntelMode: 'Deny'
    threatIntelAllowlist: {
      ipAddresses: ['10.0.1.10']
      fqdns: ['contoso.com']
    }
    intrusionDetection: {
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
            destinationAddresses: ['10.0.1.15']
            destinationPorts: ['443']
            protocol: 'TCP'
          }
        ]
      }
    }
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    transportSecurity: {
      certificateAuthority: {
        name: createFirewallCACert.outputs.certName
        keyVaultSecretId: createFirewallCACert.outputs.certSecretId
      }
    }
    resourceLock: 'CanNotDelete'
  }
}
