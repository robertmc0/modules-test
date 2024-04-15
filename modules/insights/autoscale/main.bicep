metadata name = 'Autoscale settings module'
metadata description = 'This module deploys a Microsoft.Insights/autoscalesettings resource.'
metadata owner = 'Arinco'

@description('The geo-location where the resource lives.')
param location string

@description('The resource identifier of the resource that the autoscale setting should be added to.')
param targetResourceId string

@description('The custom e-mails list. This value can be null or empty, in which case this attribute will be ignored.')
param customEmails array

@description('The collection of automatic scaling profiles that specify different scaling parameters for different time periods.')
param profiles array

var targetResourceName = last(split(targetResourceId, '/'))

resource scaleSettings 'Microsoft.Insights/autoscalesettings@2021-05-01-preview' = {
  name: '${targetResourceName}-auto-scale-setting'
  location: location
  properties: {
    enabled: true
    targetResourceUri: targetResourceId
    notifications: [
      {
        operation: 'Scale'
        email: {
          customEmails: customEmails
        }
      }
    ]
    profiles: profiles
  }
}

@description('The ID of the Autoscale Settings resource.')
output resourceId string = scaleSettings.id
