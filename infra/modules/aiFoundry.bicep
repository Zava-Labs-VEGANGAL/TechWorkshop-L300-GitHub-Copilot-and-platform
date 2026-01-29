// Azure AI Foundry (Cognitive Services) Module
// Provides AI model access for GPT-4 and Phi

@description('Name of the AI Foundry resource')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('SKU name for the AI Foundry')
@allowed([
  'S0'
  'F0'
])
param skuName string = 'S0'

@description('Kind of Cognitive Services account')
param kind string = 'OpenAI'

@description('Disable local authentication (use managed identity only)')
param disableLocalAuth bool = false

resource aiFoundry 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: {
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: disableLocalAuth
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// GPT-4o Model Deployment
resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: aiFoundry
  name: 'gpt-4o'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'
    }
  }
}

@description('Resource ID of the AI Foundry')
output id string = aiFoundry.id

@description('Name of the AI Foundry')
output name string = aiFoundry.name

@description('Endpoint URL of the AI Foundry')
output endpoint string = aiFoundry.properties.endpoint
