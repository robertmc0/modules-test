@description('The resource name.')
param name string

@description('The total amount of cost to track with the budget.')
param amount int

@description('Optional. The category of the budget, whether the budget tracks cost or usage.')
@allowed([
  'Cost'
  'Usage'
])
param category string = 'Cost'

@description('Optional. Filters to have your budget monitor with more granularity as needed.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.costmanagement/budgets?pivots=deployment-language-bicep#reportconfigfilter'
  example: {
    dimensions: {
      name: 'string'
      operator: 'string'
      values: [
        'string'
      ]
    }
  }
})
param filter object = {}

@description('Notifications associated with the budget. Budget can have up to five notifications.')
@metadata({
  NotificationForExceededBudget1: {
    enabled: true
    operator: 'GreaterThan'
    threshold: 50
    contactEmails: [ 'contactEmails' ]
  }
})
param notifications object

@description('Optional. The time covered by a budget. Tracking of the amount will be reset based on the time grain.')
@allowed([
  'Annually'
  'Monthly'
  'Quarterly'
])
param timeGrain string = 'Monthly'

@description('Start and end date of the budget. The start date must be first of the month and should be less than the end date. Future start date should not be more than three months.')
@metadata({
  startDate: 'The start date for the budget in YYYY-MM-DD format.'
  endDate: 'The end date for the budget in YYYY-MM-DD format. If not provided, will default to 10 years from the start date.'
})
param timePeriod object

resource budget 'Microsoft.CostManagement/budgets@2019-04-01-preview' = {
  name: name
  properties: {
    amount: amount
    category: category
    filter: filter
    notifications: notifications
    timeGrain: timeGrain
    timePeriod: timePeriod
  }
}

@description('The name of the deployed budget.')
output name string = budget.name

@description('The resource ID of the deployed budget.')
output resourceId string = budget.id
