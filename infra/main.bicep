// Main Bicep Template for ZavaStorefront Infrastructure
// Orchestrates all Azure resources for the e-commerce application

targetScope = 'subscription'

// =============================================
// Parameters
// =============================================

@description('Name of the environment (e.g., dev, staging, prod)')
param environmentName string

@description('Primary location for all resources')
param location string = 'westus3'

@description('Location for Azure OpenAI (must support OpenAI models)')
param openAILocation string = 'eastus'

@description('Name of the application')
param appName string = 'zavastorevegangal'

@description('Docker image name and tag (optional, uses placeholder if not provided)')
param dockerImageName string = 'mcr.microsoft.com/appsvc/staticsite:latest'

@description('Tags to apply to all resources')
param tags object = {}

// =============================================
// Variables
// =============================================

// Naming convention: {resourceType}-{appName}-{environment}-{location}
var resourceGroupName = 'rg-${appName}-${environmentName}-${location}'
var logAnalyticsName = 'log-${appName}-${environmentName}'
var appInsightsName = 'appi-${appName}-${environmentName}'
var containerRegistryName = replace('acr${appName}${environmentName}', '-', '')
var appServicePlanName = 'plan-${appName}-${environmentName}'
var webAppName = 'app-${appName}-${environmentName}'
var aiFoundryName = 'ai-${appName}-${environmentName}'

// Merge default tags with provided tags
var defaultTags = {
  'azd-env-name': environmentName
  application: appName
  environment: environmentName
}
var allTags = union(defaultTags, tags)

// =============================================
// Resource Group
// =============================================

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: allTags
}

// =============================================
// Modules
// =============================================

// Log Analytics Workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  scope: rg
  name: 'logAnalyticsDeployment'
  params: {
    name: logAnalyticsName
    location: location
    tags: allTags
    retentionInDays: 30
    skuName: 'PerGB2018'
  }
}

// Application Insights
module appInsights 'modules/appInsights.bicep' = {
  scope: rg
  name: 'appInsightsDeployment'
  params: {
    name: appInsightsName
    location: location
    tags: allTags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// Azure Container Registry
module containerRegistry 'modules/containerRegistry.bicep' = {
  scope: rg
  name: 'containerRegistryDeployment'
  params: {
    name: containerRegistryName
    location: location
    tags: allTags
    sku: 'Basic'
    adminUserEnabled: false
  }
}

// App Service Plan (Linux)
module appServicePlan 'modules/appServicePlan.bicep' = {
  scope: rg
  name: 'appServicePlanDeployment'
  params: {
    name: appServicePlanName
    location: location
    tags: allTags
    skuName: 'B1'
    kind: 'linux'
    reserved: true
  }
}

// Azure AI Foundry (OpenAI)
module aiFoundry 'modules/aiFoundry.bicep' = {
  scope: rg
  name: 'aiFoundryDeployment'
  params: {
    name: aiFoundryName
    location: openAILocation
    tags: allTags
    skuName: 'S0'
    kind: 'OpenAI'
  }
}

// Web App for Containers
module webApp 'modules/webApp.bicep' = {
  scope: rg
  name: 'webAppDeployment'
  params: {
    name: webAppName
    location: location
    tags: union(allTags, { 'azd-service-name': 'src' })
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryLoginServer: containerRegistry.outputs.loginServer
    dockerImageName: dockerImageName
    appInsightsConnectionString: appInsights.outputs.connectionString
    aiFoundryEndpoint: aiFoundry.outputs.endpoint
  }
}

// Role Assignments (AcrPull and Cognitive Services User)
module roleAssignments 'modules/roleAssignments.bicep' = {
  scope: rg
  name: 'roleAssignmentsDeployment'
  params: {
    webAppPrincipalId: webApp.outputs.principalId
    containerRegistryId: containerRegistry.outputs.id
    aiFoundryId: aiFoundry.outputs.id
  }
}

// =============================================
// Outputs
// =============================================

@description('Name of the resource group')
output AZURE_RESOURCE_GROUP string = rg.name

@description('Location of the resources')
output AZURE_LOCATION string = location

@description('URL of the Web App')
output AZURE_WEBAPP_URL string = 'https://${webApp.outputs.defaultHostname}'

@description('Name of the Web App')
output AZURE_WEBAPP_NAME string = webApp.outputs.name

@description('Container Registry login server')
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer

@description('Container Registry name')
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name

@description('Application Insights connection string')
output APPLICATIONINSIGHTS_CONNECTION_STRING string = appInsights.outputs.connectionString

@description('AI Foundry endpoint')
output AZURE_AI_FOUNDRY_ENDPOINT string = aiFoundry.outputs.endpoint

@description('AI Foundry name')
output AZURE_AI_FOUNDRY_NAME string = aiFoundry.outputs.name
