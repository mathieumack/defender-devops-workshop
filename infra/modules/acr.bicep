// ---------------------------------------------------------------------------
// modules/acr.bicep — Azure Container Registry
// ---------------------------------------------------------------------------

param location string

@description('Globally unique ACR name (3-50 alphanumeric, lowercase)')
param acrName string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'       // Basic is sufficient for demo; upgrade to Standard for geo-replication
  }
  properties: {
    adminUserEnabled: true   // Enabled for demo simplicity; in production use managed identity
  }
}

output loginServer string = acr.properties.loginServer
output acrId string = acr.id
