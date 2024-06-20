# Data collection rule association module

This module deploys Microsoft.Insights dataCollectionRuleAssociations

## Details

Deploying this module will perform the following:

- Deploys the Microsoft.Insights dataCollectionRuleAssociations resource
- This module depends on an existing DCR. Use the `dataCollectionRuleId` param to reference it.
- More so, this module requires an existing VM to be referenced. specifiy the VM name you wish to associate with the DCR using the `virtualMachineName`. The module will use the `Microsoft.Compute virtualMachines` resource to find the existing VM.
- Optionally, a data collection endpoint may also be associated with the DCR if specified

## Parameters

| Name                       | Type     | Required | Description                                                                                                                |
| :------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------- |
| `virtualMachineName`       | `string` | Yes      | Required. The VM name for the DCR to associate with.                                                                       |
| `dataCollectionRuleId`     | `string` | Yes      | Required. The resource Id of the DCR to associate the VM to.                                                               |
| `dataCollectionEndpointId` | `string` | No       | Optional. A DCR endpoint to associate with the VM and DCR with. Only used if Log analytics sits behind a network firewall. |

## Outputs

| Name         | Type     | Description                              |
| :----------- | :------: | :--------------------------------------- |
| `resourceId` | `string` | The resource Id for the DCR association. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.