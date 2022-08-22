/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'managementGroup'

@description('Optional. The geo-location where the resource lives.')
param location string = deployment().location

/*======================================================================
TEST PREREQUISITES
======================================================================*/
var policyDefinition = json(loadTextContent('main.test.initiative.json'))

/*======================================================================
TEST EXECUTION
======================================================================*/
module policy '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-policy'
  params: {
    name: policyDefinition.name
    displayName: policyDefinition.displayName
    description: policyDefinition.description
    policyDefinitions: policyDefinition.policyDefinitions
  }
}
