@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorName string

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string

@description('Endpoints to deploy to Frontdoor')
param endpoints array

@description('Origin Groups to deploy to Frontdoor')
param originGroups array

type Origin = {
  originGroupName: string
  originName: string
  hostName: string
  httpPort?: int
  httpsPort?: int
  originHostHeader: string
  enforceCertificateNameCheck?: bool
  priority?: int
  weight?: int
}

@description('Origins to deploy to Frontdoor')
param origins Origin[]

@description('Certificates to deploy to Frontdoor')
param certificates array

@description('Custom domains to deploy to Frontdoor')
param customDomains array

@description('Routes to deploy to Frontdoor')
param routes array

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'allLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'allLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Storage account resource group. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountResourceGroup string = ''

@description('Optional. Storage account name. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountName string = ''

@description('Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Event hub name. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubName string = ''

var diagnosticStorageAccountId = resourceId(diagnosticStorageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', diagnosticStorageAccountName)

var lockName = toLower('${profile.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${profile.name}-dgs')

var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

resource profile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorName
  location: 'global'
  sku: {
    name: skuName
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = [for e in endpoints: {
  name: e.endpointName
  parent: profile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}]

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = [for og in originGroups: {
  name: og.originGroupName
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: og.healthProbeEnabled && contains(og, 'healthProbeSettings') ? {
      probePath: contains(og.healthProbeSettings, 'probePath') ? og.healthProbeSettings.probePath : '/'
      probeRequestType: contains(og.healthProbeSettings, 'probeRequestType') ? og.healthProbeSettings.probeRequestType : 'HEAD'
      probeProtocol: contains(og.healthProbeSettings, 'probeProtocol') ? og.healthProbeSettings.probeProtocol : 'Https'
      probeIntervalInSeconds: contains(og.healthProbeSettings, 'probeIntervalInSeconds') ? og.healthProbeSettings.probeIntervalInSeconds : 100
    } : {}
  }
}]

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for o in origins: {
  name: '${profile.name}/${o.originGroupName}/${o.originName}'
  dependsOn: [
    originGroup
  ]
  properties: {
    hostName: o.hostName
    httpPort: o.httpPort
    httpsPort: o.httpsPort
    originHostHeader: o.originHostHeader
    enforceCertificateNameCheck: o.enforceCertificateNameCheck
    priority: o.priority
    weight: o.weight
  }
}]

resource secret 'Microsoft.Cdn/profiles/secrets@2022-11-01-preview' = [for c in certificates: {
  name: c.secretName
  parent: profile
  properties: {
    parameters: {
      type: 'CustomerCertificate'
      useLatestVersion: true
      secretSource: {
        id: c.certificateSecretId
      }
    }
  }
}]

resource customDomain 'Microsoft.Cdn/profiles/customDomains@2022-11-01-preview' = [for c in customDomains: {
  name: replace(c.customDomainName, '.', '-')
  parent: profile
  dependsOn: [
    secret // secrets must exist before the custom domains are created
  ]
  properties: {
    hostName: c.hostName
    azureDnsZone: {
      id: c.dnsZoneId
    }
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: resourceId('Microsoft.Cdn/profiles/secrets', profile.name, c.secretName)
      }
    }
  }
}]

resource ruleSet 'Microsoft.Cdn/profiles/ruleSets@2022-11-01-preview' = {
  name: 'MaintenancePageRedirects'
  parent: profile

  resource rule 'rules@2022-11-01-preview' = {
    name: 'MaintenancePageRedirectForExternal'
    properties: {
      order: 1
      matchProcessingBehavior: 'Stop'
      actions: [
        {
          name: 'UrlRedirect'
          parameters: {
            redirectType: 'TemporaryRedirect'
            destinationProtocol: 'Https'
            customHostname: 'maintenance.racgp.org.au'
            typeName: 'DeliveryRuleUrlRedirectActionParameters'
          }
        }
      ]
      conditions: [
        {
          name: 'RemoteAddress'
          parameters: {
            operator: 'IPMatch'
            typeName: 'DeliveryRuleRemoteAddressConditionParameters'
            matchValues: [
              '203.8.200.20'
            ]
            negateCondition: true
          }
        }
      ]
    }
  }
}

resource routeDef 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = [for r in routes: {
  name: '${profile.name}/${r.endpointName}/${r.routeName}'
  dependsOn: [
    origin // Ensure origins and custom domains are present before creating route
    customDomain
  ]
  properties: {
    originGroup: {
      id: resourceId('Microsoft.Cdn/profiles/origingroups', profile.name, r.originGroupName)
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    customDomains: [for c in r.customDomains: {
      id: resourceId('Microsoft.Cdn/profiles/customdomains', profile.name, replace(c, '.', '-'))
    }]
    // ruleSets: [
    //   {
    //     id: ''
    //   }
    // ]
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}]

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: profile
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: profile
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

@description('The name of the deployed Azure Frontdoor Profile.')
output name string = profile.name

output endpoints array = [for e in endpoints: e.endpointName]
