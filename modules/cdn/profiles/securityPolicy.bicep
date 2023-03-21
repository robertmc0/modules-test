param endpoints array = []
param customDomains array = []
param patternsToMatch array = [
  '/*'
]
param wafPolicyId string
param profileName string
param policyName string

var domains = concat(endpoints, customDomains)

resource profile 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: profileName
}

resource policy 'Microsoft.Cdn/profiles/securityPolicies@2022-11-01-preview' = {
  name: policyName
  parent: profile
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      associations: [
        {
          patternsToMatch: patternsToMatch
          domains: [for domain in domains: {
            id: domain.id
          }]
        }
      ]
      wafPolicy: {
        id: wafPolicyId
      }
    }
  }
}
