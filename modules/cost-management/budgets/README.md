# Budgets Module

This module deploys Microsoft.CostManagement budgets at the subscription level

## Description

This module performs the following

- Creates Microsoft.CostManagement budgets resource at the subscription level.
- Tracks cost or usage.
- Applies budget at different time grains.

## Parameters

| Name            | Type     | Required | Description                                                                                                                                                               |
| :-------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`          | `string` | Yes      | The resource name.                                                                                                                                                        |
| `amount`        | `int`    | Yes      | The total amount of cost to track with the budget.                                                                                                                        |
| `category`      | `string` | No       | Optional. The category of the budget, whether the budget tracks cost or usage.                                                                                            |
| `filter`        | `object` | No       | Optional. Filters to have your budget monitor with more granularity as needed.                                                                                            |
| `notifications` | `object` | Yes      | Notifications associated with the budget. Budget can have up to five notifications.                                                                                       |
| `timeGrain`     | `string` | No       | Optional. The time covered by a budget. Tracking of the amount will be reset based on the time grain.                                                                     |
| `timePeriod`    | `object` | Yes      | Start and end date of the budget. The start date must be first of the month and should be less than the end date. Future start date should not be more than three months. |

## Outputs

| Name         | Type     | Description                             |
| :----------- | :------: | :-------------------------------------- |
| `name`       | `string` | The name of the deployed budget.        |
| `resourceId` | `string` | The resource ID of the deployed budget. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.