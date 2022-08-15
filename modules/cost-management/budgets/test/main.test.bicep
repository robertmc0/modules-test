/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'subscription'

@description('Optional. The geo-location where the resource lives.')
param location string = deployment().location

/*======================================================================
TEST EXECUTION
======================================================================*/
module budgetMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-budget'
  params: {
    name: '${uniqueString(deployment().name, location)}-min-budget'
    amount: 500
    notifications: {
      NotificationForExceededBudget1: {
        operator: 'GreaterThan'
        threshold: 50
        contactEmails: [ 'john.smith@contoso.com' ]
      }
    }
    timePeriod: {
      startDate: '2022-08-01'
    }
  }
}

module budget '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-budget'
  params: {
    name: '${uniqueString(deployment().name, location)}-budget'
    amount: 1000
    filter: {
      dimensions: {
        name: 'ResourceType'
        operator: 'In'
        values: [
          'Microsoft.KeyVault/vaults'
        ]
      }
    }
    notifications: {
      NotificationForExceededBudget1: {
        operator: 'GreaterThan'
        threshold: 70
        contactEmails: [
          'john.smith@contoso.com'
          'jane.doe@contoso.com'
        ]
      }
      NotificationForExceededBudget2: {
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: [
          'john.smith@contoso.com'
          'jane.doe@contoso.com'
        ]
      }
      NotificationForExceededBudget3: {
        operator: 'GreaterThan'
        threshold: 95
        contactEmails: [
          'john.smith@contoso.com'
          'jane.doe@contoso.com'
        ]
      }
    }
    timePeriod: {
      startDate: '2022-08-01'
      endDate: '2022-10-01'
    }
  }
}
