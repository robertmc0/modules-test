# Managed Clusters Module

This module deploys Microsoft.ContainerService managedClusters

## Description

This module performs the following:

- Creates Microsoft.ContainerService managedClusters resource.
- Applies tags if specified
- Applies uptime SLA 'Sku' if specified.
- Applies custom node resource group if specified. Default 'MC_[resourcegroup]_[clustername]_[location]'.
- Disables static local credentials for this cluster if set to true.
- Applies custom DNS name prefix if specified. Default is [clustername].
- Applies Kubernetes Role-Based Access Control. Default is true.
- Applies the kubernetes version to specified value. Default is to use latest available.
- Applies agent pool VM sizes and configuration
- Applies network configuration if specified. Default is azure-cni.
- Adds agentpool nodes to availability zones if specified.
- Applies Azure Monitor extension if specified.
- Applies Microsoft Antimalware extension if specified.
- Applies a user assigned managed identity if specified.
- Applies diagnostic settings.
- Applies a lock to the key vault if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                                                         |
| :-------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                                                                                  |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                                                                                          |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                                                            |
| `managedClusterSku`                     | `string` | No       | Optional. Sets the uptime SLA tier to enable a financially backed, higher SLA for an AKS cluster.                                                                                                   |
| `nodeResourceGroup`                     | `string` | No       | Optional. Node resource group name.                                                                                                                                                                 |
| `disableLocalAccounts`                  | `bool`   | No       | Optional. Disable static credentials for this cluster. This must only be used on Managed Clusters that are AAD enabled.                                                                             |
| `dnsPrefix`                             | `string` | No       | Optional. Custom DNS name prefix. This cannot be updated once the Managed Cluster has been created.                                                                                                 |
| `enableRbac`                            | `bool`   | No       | Optional. Enable Kubernetes Role-Based Access Control.                                                                                                                                              |
| `kubernetesVersion`                     | `string` | No       | Optional. Specify kubernetes version to deploy.                                                                                                                                                     |
| `enablePrivateCluster`                  | `bool`   | No       | Optional. Create a private Managed Cluster.                                                                                                                                                         |
| `addonProfiles`                         | `object` | No       | Optional. Specify profile of managed cluster add-on.                                                                                                                                                |
| `agentPoolName`                         | `string` | No       | Optional. Agent Pool name.                                                                                                                                                                          |
| `agentPoolOsDiskSizeGB`                 | `int`    | No       | Optional. OS Disk Size in GB to be used to specify the disk size for every machine in the master/agent pool.                                                                                        |
| `agentPoolVnetSubnetId`                 | `string` | Yes      | Existing VNET resourceid dedicated for use with a Managed Cluster.                                                                                                                                  |
| `agentPoolMaxCount`                     | `int`    | No       | Optional. The maximum number of nodes for auto-scaling.                                                                                                                                             |
| `agentPoolMaxPods`                      | `int`    | No       | Optional. The maximum number of pods that can run on a node.                                                                                                                                        |
| `networkServiceCidr`                    | `string` | Yes      | A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.                                                                                   |
| `networkDnsServiceIp`                   | `string` | Yes      | An IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.                                                              |
| `networkDockerBridgeCidr`               | `string` | No       | Optional. A CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range. Default 172.17.0.1.                |
| `agentPoolMode`                         | `string` | No       | Optional. A cluster must have at least one "System" Agent Pool at all times. For additional information on agent pool restrictions and best practices.                                              |
| `agentPoolType`                         | `string` | No       | Optional. The type of Agent Pool.                                                                                                                                                                   |
| `enableAvailabilityZones`               | `bool`   | No       | Optional. Enable Availability zones for the agentpool nodes. This can only be specified if the AgentPoolType property is VirtualMachineScaleSets.                                                   |
| `agentPoolCount`                        | `int`    | No       | Optional. Number of agents (VMs) to host docker containers. Allowed values must be in the range of 0 to 1000 (inclusive) for user pools and in the range of 1 to 1000 (inclusive) for system pools. |
| `enableAutoScaling`                     | `bool`   | No       | Optional. Enables the Managed Cluster auto-scaler.                                                                                                                                                  |
| `agentPoolVMSize`                       | `string` | No       | Optional. Virtual Machine size of the nodes in the Managed Cluster.                                                                                                                                 |
| `networkNetworkPlugin`                  | `string` | No       | Optional. Network plugin used for building the Kubernetes network.                                                                                                                                  |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                                                                                        |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                                                                                      |
| `enableAad`                             | `bool`   | No       | Optional. Enable Azure Active Directory configuration.                                                                                                                                              |
| `enableAzureRbac`                       | `bool`   | No       | Optional. Enable Azure RBAC for Kubernetes authorization.                                                                                                                                           |
| `enableAddonAzurePolicy`                | `bool`   | No       | Optional. Enable the Azure Policy profile of managed cluster add-on.                                                                                                                                |
| `enableDefenderForCloud`                | `bool`   | No       | Optional. Enable Defender for Cloud.                                                                                                                                                                |
| `logAnalyticsWorkspaceResourceId`       | `string` | No       | Optional. Enable App Insights Monitoring. Specify App Insights Log Analytics Workspace resourceId.                                                                                                  |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                                                                |
| `upgradeChannel`                        | `string` | No       | optional. Enable auto upgrade on the AKS cluster to perform periodic upgrades to the latest Kubernetes version.                                                                                     |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                                                                    |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                                                                |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                                      |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                                                                           |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                                                                   |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                                                                             |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                                                                        |

## Outputs

| Name                      | Type   | Description                                       |
| :------------------------ | :----: | :------------------------------------------------ |
| name                      | string | The name of the deployed managed cluster.         |
| resourceId                | string | The resource ID of the deployed managed cluster.  |
| systemAssignedPrincipalId | string | The principal ID of the system assigned identity. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.