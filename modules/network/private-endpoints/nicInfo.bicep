param nicId string

var ipConfig = reference(nicId, '2021-08-01', 'Full').properties.ipConfigurations[0]

output privateIPAddress string = ipConfig.properties.privateIPAddress
output privateIPAllocationMethod string = ipConfig.properties.privateIPAllocationMethod
