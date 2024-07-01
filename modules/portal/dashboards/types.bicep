@export()
@minValue(0)
@description('A positive integer.')
type PositiveInt = int

@export()
@description('An individual tile (also known as a part) within the dashboard.')
type Tile = {
  inputs: object[]
  type: string
  settings: object
}

@export()
@description('A collection of tiles.')
type Tiles = Tile[]

@export()
@description('Describes how a given metric should be split or grouped by.')
type MetricGrouping = {
  @description('The dimension to split on. Often a property of the data like a cloud role name or status code.')
  dimension: string
  @description('The sorting order of the split data. Often 1 for ascending or 2 for descending.')
  sort: PositiveInt
  @description('The maximum number of split entities to graph.')
  top: PositiveInt
}

@export()
@description('The time range for an Application Insights query.')
type AppInsightsTimeRange = 'P1D' | 'P3D' | 'P7D'

@export()
@description('Describes a given metric within Azure Monitor.')
type Metric = {
  resourceMetadata: {
    id: string
  }
  @description('The name of the metric within the namespace. See what is available within the associated namespace for more: https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/metrics-index')
  name: string
  @description('How the metric should be aggregated, such as sum or average. See what is available within the associated namespace for more: https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/metrics-index')
  aggregationType: PositiveInt
  @description('The namespace associated to the metric. See: https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/metrics-index')
  namespace: string
  @description('How the metric should be displayed.')
  metricVisualization: {
    @description('The name to display.')
    displayName: string
    @description('The Resource Group to display.')
    resourceDisplayName: string
  }
}

@export()
@description('A collection of metrics.')
type Metrics = Metric[]

@export()
@description('How a chart should be visually displayed.')
type ChartType = 'bar' | 'area' | 'line' | 'scatter' | 'table'

@export()
@description('Describes how a given metric should be filtered.')
type Filter = {
  @description('The key or property to filter on.')
  key: string
  @description('The operator to use for the filter. Often 0 for equals or 1 for not equals.')
  operator: PositiveInt
  @description('The values to apply the operator against for the given key or property.')
  values: string[]
}

@export()
@description('A collection of filters.')
type Filters = Filter[]

@export()
@description('The position for a tile within the dashboard.')
type Position = {
  x: PositiveInt
  y: PositiveInt
  rowSpan: PositiveInt
  colSpan: PositiveInt
}

@export()
@description('A collection of positions.')
type Positions = Position[]
