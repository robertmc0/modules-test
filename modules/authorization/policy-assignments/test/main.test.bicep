/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'managementGroup'

@description('Optional. The geo-location where the resource lives.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  scope: tenant()
  name: '${shortIdentifier}-tst-mg-${uniqueString(deployment().name, 'managementGroups', location)}'
}

var policyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/013e242c-8828-4970-87b3-ab247555486d' // Azure Backup should be enabled for Virtual Machines builtin policy

/*======================================================================
TEST EXECUTION
======================================================================*/
module policyAssignmentMinimum '../main.bicep' = {
  scope: az.managementGroup(managementGroup.name)
  name: '${uniqueString(deployment().name, location)}-pol-min'
  params: {
    name: substring('${shortIdentifier}-tst-pol-asgn-min-${uniqueString(deployment().name, 'policyAssignment', location)}', 0, 24)
    location: location
    description: 'Azure Backup should be enabled for Virtual Machines'
    displayName: 'Azure Backup should be enabled for Virtual Machines'
    policyDefinitionId: policyDefinitionId
  }
}

module policyAssignment '../main.bicep' = {
  scope: az.managementGroup(managementGroup.name)
  name: '${uniqueString(deployment().name, location)}-pol'
  params: {
    name: substring('${shortIdentifier}-tst-pol-asgn-${uniqueString(deployment().name, 'policyAssignment', location)}', 0, 24)
    location: location
    description: 'Azure Backup should be enabled for Virtual Machines'
    displayName: 'Azure Backup should be enabled for Virtual Machines'
    policyDefinitionId: policyDefinitionId
    systemAssignedIdentity: true
  }
}
