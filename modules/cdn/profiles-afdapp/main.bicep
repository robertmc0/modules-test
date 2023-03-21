@description('The name of the existing Front Door Profile.')
param profileName string

@description('Endpoints to deploy to Frontdoor')
param endpoints Endpoint[]

type Endpoint = {
  name: string
  enabledState: 'Enabled' | 'Disabled'?
  policy: string?
}

@description('Origin Groups to deploy to Frontdoor')
param originGroups OriginGroup[]

type OriginGroup = {
  name: string
  loadBalancingSettings: {
    sampleSize: int
    successfulSamplesRequired: int
  }?
  healthProbeSettings: {
    probePath: string
    probeRequestType: string
    probeProtocol: string
    probeIntervalInSeconds: int
  }?
}

@description('Origins to deploy to Frontdoor')
param origins Origin[]

type Origin = {
  originGroupName: string
  originName: string
  hostName: string
  httpPort: int?
  httpsPort: int?
  originHostHeader: string
  enforceCertificateNameCheck: bool?
  priority: int?
  weight: int?
}

@description('Certificates to deploy to Frontdoor')
param secrets Secret[] = []

type Secret = {
  secretName: string
  parameters: {
    type: 'CustomerCertificate'
    useLatestVersion: bool?
    certificateSecretId: string
  }
}

@description('Custom domains to deploy to Frontdoor')
param customDomains CustomDomain[] = []

type CustomDomain = {
  customDomainName: string
  hostName: string
  dnsZoneId: string
  tlsSettings: {
    certificateType: 'CustomerCertificate' | 'ManagedCertificate'
    minimumTlsVersion: 'TLS12'
    secretName: string?
  }
  policy: string?
}

@description('Routes to deploy to Frontdoor')
param routes Route[]

type Route = {
  routeName: string
  endpointName: string
  originGroupName: string
  supportedProtocols: [
    'Http'
    'Https'
  ]?
  patternsToMatch: [
    '/*'
  ]?
  forwardingProtocol: 'HttpsOnly' | 'HttpOnly'
  customDomains: Domain[]?
  ruleSets: ResourceReference[]?
  linkToDefaultDomain: string?
  httpsRedirect: string?
  cacheConfiguration: object?
}

type Domain = {
  name: string
}

type ResourceReference = {
  id: string
}

@description('Security Policies to deploy to Frontdoor')
param securityPolicies SecurityPolicy[] = []

type SecurityPolicy = {
  name: string
  //associations: SecurityPolicyAssociations[]
  wafPolicyId: string
  patternsToMatch: array?
}

type SecurityPolicyAssociations = {
  domains: Domain[]
}

resource profile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: profileName
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = [for e in endpoints: {
  name: e.name
  parent: profile
  location: 'global'
  properties: {
    enabledState: contains(e, 'enabledState') ? e.enabledState : 'Enabled'
  }
}]

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = [for og in originGroups: {
  name: og.name
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: og.?healthProbeSettings.?probePath ?? '/'
      probeRequestType: og.?healthProbeSettings.?probeRequestType ?? 'HEAD'
      probeProtocol: og.?healthProbeSettings.?probeProtocol ?? 'Https'
      probeIntervalInSeconds: og.?healthProbeSettings.?probeIntervalInSeconds
    }
  }
}]

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for o in origins: {
  #disable-next-line use-parent-property
  name: '${profile.name}/${o.originGroupName}/${o.originName}'
  dependsOn: [
    originGroup
  ]
  properties: {
    hostName: o.hostName
    httpPort: contains(o, 'httpPort') ? o.httpPort : 80
    httpsPort: contains(o, 'httpsPort') ? o.httpsPort : 443
    originHostHeader: contains(o, 'originHostHeader') ? o.originHostHeader : ''
    enforceCertificateNameCheck: contains(o, 'enforceCertificateNameCheck') ? o.enforceCertificateNameCheck : true
    priority: contains(o, 'priority') ? o.priority : 1
    weight: contains(o, 'weight') ? o.weight : 100
  }
}]

resource secret 'Microsoft.Cdn/profiles/secrets@2022-11-01-preview' = [for s in secrets: {
  name: s.secretName
  parent: profile
  properties: {
    parameters: {
      type: 'CustomerCertificate'
      useLatestVersion: true
      secretSource: {
        #disable-next-line use-resource-id-functions
        id: s.parameters.certificateSecretId
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
      #disable-next-line use-resource-id-functions
      id: c.dnsZoneId
    }
    tlsSettings: {
      certificateType: c.tlsSettings.certificateType
      minimumTlsVersion: 'TLS12'
      secret: c.tlsSettings.certificateType == 'CustomerCertificate' ? {
        id: az.resourceId('Microsoft.Cdn/profiles/secrets', profile.name, c.tlsSettings.secretName ?? 'undefined')
      } : null
    }
  }
}]

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = [for r in routes: {
  #disable-next-line use-parent-property
  name: '${profile.name}/${r.endpointName}/${r.routeName}'
  dependsOn: [
    origin // Ensure origins, custom domains are present before creating route
    customDomain
  ]
  properties: {
    originGroup: {
      id: az.resourceId('Microsoft.Cdn/profiles/origingroups', profile.name, r.originGroupName)
    }
    supportedProtocols: contains(r, 'supportedProtocols') ? r.supportedProtocols : [ 'Https' ]
    patternsToMatch: contains(r, 'patternsToMatch') ? r.patternsToMatch : []
    forwardingProtocol: contains(r, 'forwardingProtocol') ? r.forwardingProtocol : 'HttpsOnly'
    customDomains: [for c in r.customDomains ?? []: {
      id: az.resourceId('Microsoft.Cdn/profiles/customdomains', profile.name, replace(c.name, '.', '-'))
    }]
    ruleSets: [for rs in r.?ruleSets ?? []: {
      #disable-next-line use-resource-id-functions
      id: rs.id
    }]
    linkToDefaultDomain: contains(r, 'linkToDefaultDomain') ? r.linkToDefaultDomain : 'Enabled'
    httpsRedirect: contains(r, 'httpsRedirect') ? r.httpsRedirect : 'Enabled'
    cacheConfiguration: r.?cacheConfiguration
  }
}]

var endpointsWithPolicy = map(filter(endpoints, e => !empty(e.?policy)), e => {
    policy: e.policy
    id: az.resourceId('Microsoft.Cdn/profiles/afdEndpoints', profile.name, e.name)
  })
var customDomainsWithPolicy = map(filter(customDomains, c => !empty(c.?policy)), c => {
    policy: c.policy
    id: az.resourceId('Microsoft.Cdn/profiles/customDomains', profile.name, c.customDomainName)
  })
var domainsWithPolicy = union(endpointsWithPolicy, customDomainsWithPolicy)

resource policy 'Microsoft.Cdn/profiles/securityPolicies@2022-11-01-preview' = [for s in securityPolicies: {
  name: s.name
  parent: profile
  dependsOn: [
    endpoint
    customDomain
  ]
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      associations: [
        {
          patternsToMatch: s.?patternsToMatch ?? [ '/*' ]
          domains: [for d in filter(domainsWithPolicy, f => f.policy == s.name): {
            #disable-next-line use-resource-id-functions
            id: d.id
          }]
        }
      ]
      wafPolicy: {
        #disable-next-line use-resource-id-functions
        id: s.wafPolicyId
      }
    }
  }
}]

output endpoints array = [for (name, i) in endpoints: {
  id: endpoint[i].id
  name: name
}]
output customDomains array = [for (name, i) in customDomains: {
  id: customDomain[i].id
  name: name
}]
