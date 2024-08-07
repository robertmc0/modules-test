import * as Types from './types.bicep'

@export()
@description('Converts a ChartType to the format expected by Azure Monitor.')
func ChartTypeToInt(type Types.ChartType) int => type == 'line' ? 0
: type == 'bar' ? 1 
: type == 'table' ? 5
: type == 'area' ? 3 
: type == 'scatter' ? 4
: 0

@export()
@description('Creates a new Application Insights tile. This tile will display the results of the provided query.')
func createApplicationInsightsTile(timeRange Types.AppInsightsTimeRange, query string, title string, subTitle string, scope string) Types.Tile => {
  inputs: [
    {
      name: 'resourceTypeMode'
      isOptional: true
    }
    {
      name: 'ComponentId'
      isOptional: true
    }
    {
      name: 'Scope'
      value: {
        resourceIds: [
          '${scope}'
        ]
      }
      isOptional: true
    }
    {
      name: 'PartId'
      value: guid(query)
      isOptional: true
    }
    {
      name: 'Version'
      value: 2
      isOptional: true
    }
    {
      name: 'TimeRange'
      value: timeRange
      isOptional: true
    }
    {
      name: 'DashboardId'
      isOptional: true
    }
    {
      name: 'DraftRequestParameters'
      isOptional: true
    }
    {
      name: 'Query'
      value: query
      isOptional: true
    }
    {
      name: 'ControlType'
      value: 'AnalyticsGrid'
      isOptional: true
    }
    {
      name: 'SpecificChart'
      isOptional: true
    }
    {
      name: 'PartTitle'
      value: 'Analytics'
      isOptional: true
    }
    {
      name: 'PartSubTitle'
      value: subTitle
      isOptional: true
    }
    {
      name: 'Dimensions'
      isOptional: true
    }
    {
      name: 'LegendOptions'
      isOptional: true
    }
    {
      name: 'IsQueryContainTimeRange'
      value: false
      isOptional: true
    }
  ]
  type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
  settings: {
    content: {
      GridColumnsWidth: {

      }
      Query: query
      PartTitle: title
    }
  }
}

@export()
@description('Creates a new Azure Monitor metrics tile. This tile is used to visualize metrics data for most Azure resources.')
func createAzureMonitorTile(title string, chartType Types.ChartType, metrics Types.Metrics, filters Types.Filters?, grouping Types.MetricGrouping?) Types.Tile => {
  inputs: [
    {
      name: 'options'
      isOptional: true
    }
    {
      name: 'sharedTimeRange'
      isOptional: true
    }
  ]
  type: 'Extension/HubsExtension/PartType/MonitorChartPart'
  settings: {
    content: {
      options: {
        chart: {
          metrics: metrics
          title: title
          titleKind: 2
          visualization: {
            chartType: ChartTypeToInt(chartType)
            legendVisualization: {
              isVisible: true
              position: 2
              hideHoverCard: false
              hideLabelNames: false
            }
            axisVisualization: {
              x: {
                isVisible: true
                axisType: 2
              }
              y: {
                isVisible: true
                axisType: 1
              }
            }
            disablePinning: true
          }
          grouping: grouping ?? {}
          filterCollection: {
            filters: filters ?? []
          }
        }
      }
    }
  }
}

@export()
@description('Creates a miscellaneous tile. This is an escape hatch for when the built-in tiles are not enough and more customization is needed.')
func createMiscellaneousTile(type string, inputs[], settings object) Types.Tile => {
  inputs: inputs
  type: type
  settings: settings
}
