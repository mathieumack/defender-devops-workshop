// ---------------------------------------------------------------------------
// modules/log-analytics.bicep — Log Analytics workspace
// ---------------------------------------------------------------------------

param location string
param workspaceName string

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

output workspaceId string = workspace.id
output customerId string = workspace.properties.customerId

@description('Primary shared key — consumed as @secure() parameter downstream')
output sharedKey string = workspace.listKeys().primarySharedKey
