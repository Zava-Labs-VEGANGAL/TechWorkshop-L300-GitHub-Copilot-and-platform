// App Service Plan Module
// Provides the hosting plan for the Web App

@description('Name of the App Service Plan')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('SKU name for the App Service Plan')
@allowed([
  'F1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
  'P1v3'
  'P2v3'
  'P3v3'
])
param skuName string = 'B1'

@description('Kind of App Service Plan (linux for containers)')
param kind string = 'linux'

@description('Reserved for Linux (must be true for Linux)')
param reserved bool = true

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: {
    name: skuName
  }
  properties: {
    reserved: reserved
  }
}

@description('Resource ID of the App Service Plan')
output id string = appServicePlan.id

@description('Name of the App Service Plan')
output name string = appServicePlan.name
