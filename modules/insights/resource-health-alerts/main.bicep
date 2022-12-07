@description('The resource name.')
param name string

@description('Action Group Resource IDs.')
param actionGroupIds array

@description('Optional. A list of resource IDs that will be used as prefixes. The alert will only apply to Activity Log events with resource IDs that fall under one of these prefixes.')
param scopes array = [
  subscription().id
]

@description('Optional. A list of resource type resource IDs to filter against. Leave empty to add all resource types.')
param resourceTypes array = []

var baseCondition = [
  {
    field: 'category'
    equals: 'ResourceHealth'
  }
  {
    anyOf: [
      {
        field: 'properties.currentHealthStatus'
        equals: 'Available'
      }
      {
        field: 'properties.currentHealthStatus'
        equals: 'Unavailable'
      }
      {
        field: 'properties.currentHealthStatus'
        equals: 'Degraded'
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'properties.previousHealthStatus'
        equals: 'Available'
      }
      {
        field: 'properties.previousHealthStatus'
        equals: 'Unavailable'
      }
      {
        field: 'properties.previousHealthStatus'
        equals: 'Degraded'
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'properties.cause'
        equals: 'PlatformInitiated'
      }
    ]
  }
  {
    anyOf: [
      {
        field: 'status'
        equals: 'Active'
      }
      {
        field: 'status'
        equals: 'Resolved'
      }
      {
        field: 'status'
        equals: 'In Progress'
      }
      {
        field: 'status'
        equals: 'Updated'
      }
    ]
  }
]

var resourceTypeArray = [for type in resourceTypes: {
  field: 'resourceType'
  equals: type
}]

var resourceTypeFilter = [ {
    anyOf: resourceTypeArray
  } ]

var condition = empty(resourceTypes) ? baseCondition : union(baseCondition, resourceTypeFilter)

resource resourceHealthAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: name
  location: 'Global'
  properties: {
    enabled: true
    scopes: scopes
    condition: {
      allOf: condition
    }
    actions: {
      actionGroups: [for actionGroup in actionGroupIds: {
        actionGroupId: actionGroup
      }]
    }
  }
}

@description('The name of the deployed resource health alert.')
output name string = resourceHealthAlert.name

@description('The resource ID of the deployed resource health alert.')
output resourceId string = resourceHealthAlert.id
