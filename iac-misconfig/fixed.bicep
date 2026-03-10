// ---------------------------------------------------------------------------
// iac-misconfig/fixed.bicep — Remediated IaC
// ---------------------------------------------------------------------------
// This template resolves all issues found in vulnerable.bicep.
// Each fix is documented inline.
// ---------------------------------------------------------------------------

param location string = resourceGroup().location
param storageAccountName string = 'stdemofixed'

@secure()
@description('SQL admin password — injected at deploy time, never stored in code')
param sqlAdminPassword string

// ── FIX 1: Storage account hardened ─────────────────────────────────────────
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: false          // FIX: no anonymous blob access
    supportsHttpsTrafficOnly: true        // FIX: enforce HTTPS
    minimumTlsVersion: 'TLS1_2'          // FIX: require TLS 1.2+
  }
}

// ── FIX 2: NSG with restrictive rules ───────────────────────────────────────
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-demo-fixed'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsFromCorpOnly'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'                   // FIX: TCP only
          sourceAddressPrefix: '10.0.0.0/8' // FIX: corporate CIDR only
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'        // FIX: HTTPS port only
        }
      }
      {
        name: 'DenyAllOther'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// ── FIX 3: SQL Server hardened ──────────────────────────────────────────────
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: 'sql-demo-fixed'
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: sqlAdminPassword    // FIX: password via @secure() param
    publicNetworkAccess: 'Disabled'                 // FIX: no public access
    minimalTlsVersion: '1.2'                        // FIX: TLS 1.2+
  }
}
