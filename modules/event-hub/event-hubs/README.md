# EventHub Module

This module deploys an EventHub (Microsoft.EventHub/namespaces/EventHubs) resource.

## Details

This module deploys an EventHub (Microsoft.EventHub/namespaces/EventHubs) to an existing EventHub namespace.

## Parameters

| Name                     | Type     | Required | Description                                                      |
| :----------------------- | :------: | :------: | :--------------------------------------------------------------- |
| `name`                   | `string` | Yes      | The name of the resource.                                        |
| `messageRetentionInDays` | `int`    | Yes      | How many days to retain the message.                             |
| `partitionCount`         | `int`    | Yes      | Number of partitions in the Event Hub.                           |
| `scope`                  | `string` | Yes      | Resource ID of the EventHub namespace to associate Event Hub to. |
| `resourceLock`           | `string` | No       | Optional. Specify the type of resource lock.                     |

## Outputs

| Name         | Type     | Description                               |
| :----------- | :------: | :---------------------------------------- |
| `name`       | `string` | The name of the deployed resource.        |
| `resourceId` | `string` | The resource ID of the deployed resource. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.