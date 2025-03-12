# Managed Clusters Module

This module deploys Microsoft.ContainerService managedClusters

## Details

This module performs the following:

- Creates Microsoft.ContainerService managedClusters resource.
- Applies tags if specified.
- Applies uptime SLA 'Sku' if specified.
- Applies custom node resource group if specified. Default 'MC_[resourcegroup]_[clustername]_[location]'.
- Disables static local credentials for this cluster if set to true.
- Applies custom DNS name prefix if specified. Default is [clustername].
- Applies Kubernetes Role-Based Access Control. Default is true.
- Applies the kubernetes version to specified value. Default is to use latest available.
- Applies agent pool VM sizes and configuration.
- Applies agent pool autoscaler configuration if enabled.
- Applies network configuration if specified. Default is azure-cni.
- Adds agentpool nodes to availability zones if specified.
- Applies Azure Monitor extension if specified.
- Applies Microsoft Antimalware extension if specified.
- Applies a user assigned managed identity if specified.
- Applies diagnostic settings.
- Applies a lock to the cluster if the lock is specified.

## Parameters

| Name                                            | Type     | Required | Description                                                                                                                            |
| :---------------------------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                          | `string` | Yes      | The resource name.                                                                                                                     |
| `location`                                      | `string` | Yes      | The geo-location where the resource lives.                                                                                             |
| `tags`                                          | `object` | No       | Optional. Resource tags.                                                                                                               |
| `managedClusterSku`                             | `string` | No       | Optional. Sets the uptime SLA tier to enable a financially backed, higher SLA for an AKS cluster.                                      |
| `nodeResourceGroup`                             | `string` | No       | Optional. Node resource group name.                                                                                                    |
| `disableLocalAccounts`                          | `bool`   | No       | Optional. Disable static credentials for this cluster. This must only be used on Managed Clusters that are AAD enabled.                |
| `dnsPrefix`                                     | `string` | No       | Optional. Custom DNS name prefix. This cannot be updated once the Managed Cluster has been created.                                    |
| `enableRbac`                                    | `bool`   | No       | Optional. Enable Kubernetes Role-Based Access Control.                                                                                 |
| `kubernetesVersion`                             | `string` | No       | Optional. Specify kubernetes version to deploy.                                                                                        |
| `enablePrivateCluster`                          | `bool`   | No       | Optional. Create a private Managed Cluster.                                                                                            |
| `addonProfiles`                                 | `object` | No       | Optional. Specify profile of managed cluster add-on.                                                                                   |
| `agentPoolProfiles`                             | `array`  | Yes      | Required. Properties of the primary agent pool.                                                                                        |
| `networkPodCidr`                                | `string` | No       | A CIDR notation IP range from which to assign pod IPs when kubenet is used. It must not overlap with any Subnet IP ranges.             |
| `networkServiceCidr`                            | `string` | Yes      | A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.                      |
| `networkDnsServiceIp`                           | `string` | Yes      | An IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr. |
| `networkNetworkPlugin`                          | `string` | No       | Optional. Network plugin used for building the Kubernetes network.                                                                     |
| `networkNetworkPluginMode`                      | `string` | No       | Optional. Network plugin mode used for building the Kubernetes network.                                                                |
| `networkNetworkDataplane`                       | `string` | No       | Optional. Network dataplane used in the Kubernetes cluster.                                                                            |
| `networkOutboundType`                           | `string` | No       | Optional. Network dataplane used in the Kubernetes cluster.                                                                            |
| `istioServiceMeshEnabled`                       | `bool`   | No       | Optional. Enable Istio Service Mesh.                                                                                                   |
| `istioServiceMeshInternalIngressGatewayEnabled` | `bool`   | No       | Optional. Enable Istio Service Mesh Internal Ingress Gateway.                                                                          |
| `istioServiceMeshExternalIngressGatewayEnabled` | `bool`   | No       | Optional. Enable Istio Service Mesh External Ingress Gateway.                                                                          |
| `istioServiceMeshRevision`                      | `string` | No       | Optional. Istio Service Mesh Control Plane Revision.                                                                                   |
| `enableAad`                                     | `bool`   | No       | Optional. Enable Azure Active Directory configuration.                                                                                 |
| `enableAzureRbac`                               | `bool`   | No       | Optional. Enable Azure RBAC for Kubernetes authorization.                                                                              |
| `enableAddonAzurePolicy`                        | `bool`   | No       | Optional. Enable the Azure Policy profile of managed cluster add-on.                                                                   |
| `upgradeChannel`                                | `string` | No       | optional. Enable auto upgrade on the AKS cluster to perform periodic upgrades to the latest Kubernetes version.                        |
| `userAssignedIdentities`                        | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                         |
| `enableDefenderForCloud`                        | `bool`   | No       | Optional. Enable Defender for Cloud.                                                                                                   |
| `resourceLock`                                  | `string` | No       | Optional. Specify the type of resource lock.                                                                                           |
| `logAnalyticsWorkspaceResourceId`               | `string` | No       | Optional. Enable App Insights Monitoring. Specify App Insights Log Analytics Workspace resourceId.                                     |
| `enableDiagnostics`                             | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                   |
| `diagnosticLogCategoryGroupsToEnable`           | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                       |
| `diagnosticMetricsToEnable`                     | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                   |
| `diagnosticStorageAccountId`                    | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                              |
| `diagnosticLogAnalyticsWorkspaceId`             | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                      |
| `diagnosticEventHubAuthorizationRuleId`         | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                |
| `diagnosticEventHubName`                        | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                           |

## Outputs

| Name                        | Type     | Description                                               |
| :-------------------------- | :------: | :-------------------------------------------------------- |
| `name`                      | `string` | The name of the deployed managed cluster.                 |
| `resourceId`                | `string` | The resource ID of the deployed managed cluster.          |
| `systemAssignedPrincipalId` | `string` | The principal ID of the system assigned identity.         |
| `nodeResourceGroupName`     | `string` | The name of the deployed managed cluster.                 |
| `secretProviderPrincipalId` | `string` | The Object ID of the Key Vault Secrets Provider identity. |
| `kubeletIdentityObjectId`   | `string` | The Object ID of the AKS kubelet identity.                |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.