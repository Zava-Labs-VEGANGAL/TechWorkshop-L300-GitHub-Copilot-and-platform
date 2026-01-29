// Web App for Containers Module
// Deploys Linux Web App with Docker container support and managed identity

@description('Name of the Web App')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('Resource ID of the App Service Plan')
param appServicePlanId string

@description('Container Registry login server URL')
param containerRegistryLoginServer string

@description('Docker image name and tag')
param dockerImageName string = 'mcr.microsoft.com/appsvc/staticsite:latest'

@description('Application Insights connection string')
param appInsightsConnectionString string = ''

@description('AI Foundry endpoint URL')
param aiFoundryEndpoint string = ''

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerImageName}'
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryLoginServer}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'AZURE_AI_FOUNDRY_ENDPOINT'
          value: aiFoundryEndpoint
        }
      ]
    }
  }
}

@description('Resource ID of the Web App')
output id string = webApp.id

@description('Name of the Web App')
output name string = webApp.name

@description('Default hostname of the Web App')
output defaultHostname string = webApp.properties.defaultHostName

@description('Principal ID of the Web App managed identity')
output principalId string = webApp.identity.principalId
