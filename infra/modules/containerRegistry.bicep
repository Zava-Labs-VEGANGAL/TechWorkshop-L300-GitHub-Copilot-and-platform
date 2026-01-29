// Azure Container Registry Module
// Provides container image storage with RBAC-based authentication

@description('Name of the Container Registry (must be globally unique)')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('SKU for the Container Registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Enable admin user (should be false for RBAC-based auth)')
param adminUserEnabled bool = false

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
    }
  }
}

@description('Resource ID of the Container Registry')
output id string = containerRegistry.id

@description('Name of the Container Registry')
output name string = containerRegistry.name

@description('Login server URL')
output loginServer string = containerRegistry.properties.loginServer
