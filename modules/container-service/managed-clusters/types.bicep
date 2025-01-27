@export()
@description('The type for an agent pool.')
type agentPoolType = {
  @description('Required. The name of the agent pool.')
  name: string

  @description('Optional. The availability zones of the agent pool.')
  availabilityZones: int[]?

  @description('Optional. The number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive).')
  count: int?

  @description('Optional. Whether to enable auto-scaling for the agent pool.')
  enableAutoScaling: bool?

  @description('Optional. Whether to enable encryption at host for the agent pool.')
  enableEncryptionAtHost: bool?

  @description('Optional. The maximum number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive).')
  maxCount: int?

  @description('Optional. The minimum number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive).')
  minCount: int?

  @description('Optional. The maximum number of pods that can run on a node.')
  maxPods: int?

  @description('Optional. The minimum number of pods that can run on a node.')
  minPods: int?

  @description('Optional. The mode of the agent pool.')
  mode: ('System' | 'User')?

  @description('Optional. The node labels of the agent pool.')
  nodeLabels: object?

  @description('Optional. The node taints of the agent pool.')
  nodeTaints: string[]?

  @description('Optional. The OS disk size in GB of the agent pool.')
  osDiskSizeGB: int?

  @description('Optional. The OS disk type of the agent pool.')
  osDiskType: string?

  @description('Optional. The OS SKU of the agent pool.')
  osSku: string?

  @description('Optional. The OS type of the agent pool.')
  osType: ('Linux' | 'Windows')?

  @description('Optional. The pod subnet ID of the agent pool.')
  podSubnetResourceId: string?

  @description('Optional. The tags of the agent pool.')
  tags: object?

  @description('Optional. The type of the agent pool.')
  type: ('AvailabilitySet' | 'VirtualMachineScaleSets')?

  @description('Optional. The VM size of the agent pool.')
  vmSize: string?

  @description('Optional. The VNet subnet ID of the agent pool.')
  vnetSubnetResourceId: string?

  @description('Optional. The workload runtime of the agent pool.')
  workloadRuntime: string?
}
