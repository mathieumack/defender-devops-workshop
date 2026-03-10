// ---------------------------------------------------------------------------
// iac-misconfig/vulnerable.bicep — Intentionally Misconfigured IaC
// ---------------------------------------------------------------------------
// This template contains INTENTIONAL misconfigurations that will be flagged
// by IaC scanners (Microsoft Security DevOps / Checkov / tfsec / Terrascan).
//
// Each issue is marked with a comment explaining the misconfiguration.
// See fixed.bicep for the remediated version.
// ---------------------------------------------------------------------------

param location string = resourceGroup().location
param storageAccountName string = 'stdemovulnerable'

// ── ISSUE 1: Storage account with public blob access enabled ────────────────
// WHY: Allows anonymous read access to blobs. Flagged as high severity.
// FIX: Set allowBlobPublicAccess to false (see fixed.bicep).
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: true          // VULNERABLE: public blob access
    supportsHttpsTrafficOnly: false      // VULNERABLE: allows HTTP (unencrypted)
    minimumTlsVersion: 'TLS1_0'         // VULNERABLE: outdated TLS version
  }
}

// ── ISSUE 2: Network Security Group with overly permissive inbound rule ─────
// WHY: Allows all inbound traffic from any source on any port (0.0.0.0/0).
// FIX: Restrict source addresses and ports (see fixed.bicep).
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-demo-vulnerable'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAll'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'                   // VULNERABLE: all protocols
          sourceAddressPrefix: '*'        // VULNERABLE: any source
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '0-65535' // VULNERABLE: all ports
        }
      }
    ]
  }
}

// ── ISSUE 3: SQL Server without auditing and with public network access ─────
// WHY: Missing audit logging and exposed to the internet.
// FIX: Enable auditing & restrict network access (see fixed.bicep).
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: 'sql-demo-vulnerable'
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: 'P@ssw0rd123!'     // VULNERABLE: weak password in template
    publicNetworkAccess: 'Enabled'                  // VULNERABLE: public network access
    minimalTlsVersion: '1.0'                        // VULNERABLE: outdated TLS
  }
}
