import * as Types from './types.bicep'
import * as Functions from './functions.bicep'

metadata name = 'Operational Insights Dashboard Module.'
metadata description = 'This module deploys a Microsoft.Portal/dashboards resource.'
metadata owner = 'Arinco'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. The location for the dashboard.')
param location string = resourceGroup().location

@description('Optional. A given set of tile positions that overrides the default layout.')
param tilePositions Types.Positions = []

@description('The name for the dashboard.')
param name string

@description('The array of tiles that make up the Dashboard visually.')
param tiles Types.Tiles

@description('The maximum number of tiles per row in the dashboard.')
param rowCount Types.PositiveInt = 3

@description('The maximum number of tiles per column in the dashboard.')
param columnCount Types.PositiveInt = 3

@description('The width of each tile.')
param tileWidth Types.PositiveInt = 6

@description('The height of each tile.')
param tileHeight Types.PositiveInt = 4

var cells = [
  for i in range(0, rowCount * columnCount): {
    row: i / columnCount
    col: i % columnCount
    index: i
  }
]

var parts = [
  for (tile, i) in tiles: {
    position: tilePositions[?i] ?? {
      x: cells[i].col * tileWidth
      y: cells[i].row * tileHeight
      rowSpan: tileHeight
      colSpan: tileWidth
    }    
    #disable-next-line BCP036
    metadata: tile
  }
]

resource dashboard 'Microsoft.Portal/dashboards@2020-09-01-preview' = {
  name: name
  tags: tags
  location: location
  properties: {
    lenses: [
      {
        order: 0
        parts: parts
      }
    ]
    metadata: {
      model: {
        timeRange: {
          value: {
            relative: {
              duration: 24
              timeUnit: 1
            }
          }
          type: 'MsPortalFx.Composition.Configuration.ValueTypes.TimeRange'
        }
        filterLocale: {
          value: 'en-us'
        }
        filters: {
          value: {
            MsPortalFx_TimeRange: {
              model: {
                format: 'utc'
                granularity: 'auto'
                relative: '24h'
              }
              displayCache: {
                name: 'UTC Time'
                value: 'Past 24 hours'
              }
              filteredPartIds: []
            }
          }
        }
      }
    }
  }
}

output resourceId string = dashboard.id
