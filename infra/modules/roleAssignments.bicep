// Role Assignments Module
// Assigns RBAC roles to the Web App managed identity

@description('Principal ID of the Web App managed identity')
param webAppPrincipalId string

@description('Resource ID of the Container Registry')
param containerRegistryId string

@description('Resource ID of the AI Foundry')
param aiFoundryId string

// AcrPull role definition ID
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

// Cognitive Services User role definition ID
var cognitiveServicesUserRoleId = 'a97b65f3-24c7-4388-baec-2e87135dc908'

// Reference existing Container Registry for role assignment
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: last(split(containerRegistryId, '/'))
}

// Reference existing AI Foundry for role assignment
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: last(split(aiFoundryId, '/'))
}

// Assign AcrPull role to Web App managed identity on Container Registry
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistryId, webAppPrincipalId, acrPullRoleId)
  scope: containerRegistry
  properties: {
    principalId: webAppPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalType: 'ServicePrincipal'
  }
}

// Assign Cognitive Services User role to Web App managed identity on AI Foundry
resource cognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiFoundryId, webAppPrincipalId, cognitiveServicesUserRoleId)
  scope: aiFoundry
  properties: {
    principalId: webAppPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesUserRoleId)
    principalType: 'ServicePrincipal'
  }
}

@description('AcrPull role assignment ID')
output acrPullRoleAssignmentId string = acrPullRoleAssignment.id

@description('Cognitive Services User role assignment ID')
output cognitiveServicesUserRoleAssignmentId string = cognitiveServicesUserRoleAssignment.id
