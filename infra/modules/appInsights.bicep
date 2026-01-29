// Application Insights Module
// Provides application monitoring and telemetry

@description('Name of the Application Insights resource')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('Resource ID of the Log Analytics Workspace')
param logAnalyticsWorkspaceId string

@description('Application type')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: logAnalyticsWorkspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    RetentionInDays: 90
  }
}

@description('Resource ID of the Application Insights')
output id string = applicationInsights.id

@description('Name of the Application Insights')
output name string = applicationInsights.name

@description('Instrumentation Key')
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Connection String')
output connectionString string = applicationInsights.properties.ConnectionString
