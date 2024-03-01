# Data collection rule association module

This module deploys Microsoft.Insights dataCollectionRuleAssociations

## Details

{{Add detailed information about the module}}

## Parameters

| Name                       | Type     | Required | Description                                                                                                               |
| :------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------ |
| `virtualMachineName`       | `string` | Yes      | Required. The VM name for the DCR to associate with                                                                       |
| `dataCollectionRuleId`     | `string` | Yes      | Required. The resource Id of the DCR to associate the VM to                                                               |
| `dataCollectionEndpointId` | `string` | No       | Optional. A DCR endpoint to associate with the VM and DCR with. Only used if Log analytics sits behind a network firewall |

## Outputs

| Name            | Type     | Description                             |
| :-------------- | :------: | :-------------------------------------- |
| `associationId` | `string` | The resource Id for the DCR association |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```