// Log Analytics Workspace Module
// Provides centralized logging for Application Insights and other resources

@description('Name of the Log Analytics Workspace')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('Retention in days (30-730)')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('SKU name')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
])
param skuName string = 'PerGB2018'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('Resource ID of the Log Analytics Workspace')
output id string = logAnalyticsWorkspace.id

@description('Name of the Log Analytics Workspace')
output name string = logAnalyticsWorkspace.name

@description('Customer ID (Workspace ID) of the Log Analytics Workspace')
output customerId string = logAnalyticsWorkspace.properties.customerId
