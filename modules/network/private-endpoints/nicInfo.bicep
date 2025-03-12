@description('Network Interface Id.')
param nicId string

var ipConfig = reference(nicId, '2021-08-01', 'Full').properties.ipConfigurations[0]

@description('Network Interface Private IP Address.')
output privateIPAddress string = ipConfig.properties.privateIPAddress

@description('Network Interface Private IP Allocation Method.')
output privateIPAllocationMethod string = ipConfig.properties.privateIPAllocationMethod
