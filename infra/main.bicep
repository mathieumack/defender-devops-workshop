// ---------------------------------------------------------------------------
// main.bicep — Deploys the full demo environment for Defender for DevOps
// ---------------------------------------------------------------------------
// Usage:
//   az deployment sub create \
//     --location eastus \
//     --template-file infra/main.bicep \
//     --parameters infra/parameters.json
// ---------------------------------------------------------------------------

targetScope = 'subscription'

@description('Azure region for all resources')
param location string = 'eastus'

@description('Name of the demo resource group')
param resourceGroupName string = 'rg-defender-devops-demo'

@description('Globally unique name for Azure Container Registry (3-50 alphanumeric)')
param acrName string

@description('Name for the Container App')
param appName string = 'demo-api'

@description('Container image tag to deploy (set after first build)')
param imageTag string = 'latest'

@description('Enable Defender for Cloud plans')
param enableDefender bool = true

// ---------------------------------------------------------------------------
// Resource Group
// ---------------------------------------------------------------------------
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: {
    purpose: 'defender-devops-demo'
    environment: 'lab'
  }
}

// ---------------------------------------------------------------------------
// Log Analytics (needed by Container Apps and Defender)
// ---------------------------------------------------------------------------
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics'
  scope: rg
  params: {
    location: location
    workspaceName: 'law-${appName}'
  }
}

// ---------------------------------------------------------------------------
// Azure Container Registry
// ---------------------------------------------------------------------------
module acr 'modules/acr.bicep' = {
  name: 'acr'
  scope: rg
  params: {
    location: location
    acrName: acrName
  }
}

// ---------------------------------------------------------------------------
// Container Apps environment + application
// ---------------------------------------------------------------------------
module containerApp 'modules/container-app.bicep' = {
  name: 'container-app'
  scope: rg
  params: {
    location: location
    appName: appName
    acrLoginServer: acr.outputs.loginServer
    acrName: acrName
    imageTag: imageTag
    logAnalyticsCustomerId: logAnalytics.outputs.customerId
    logAnalyticsSharedKey: logAnalytics.outputs.sharedKey
  }
}

// Grant Container App managed identity AcrPull role on the ACR
module acrPullRole 'modules/acr-role.bicep' = {
  name: 'acr-pull-role'
  scope: rg
  params: {
    acrName: acrName
    principalId: containerApp.outputs.principalId
  }
}

// ---------------------------------------------------------------------------
// Defender for Cloud plans (optional — can be enabled separately)
// ---------------------------------------------------------------------------
// Defender for Cloud pricing plans must target subscription scope (not RG)
module defender 'modules/defender.bicep' = if (enableDefender) {
  name: 'defender-plans'
  // No scope = inherits subscription from targetScope
  params: {}
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
output resourceGroupName string = rg.name
output acrLoginServer string = acr.outputs.loginServer
output containerAppFqdn string = containerApp.outputs.fqdn
