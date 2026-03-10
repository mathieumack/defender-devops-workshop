// ---------------------------------------------------------------------------
// modules/defender.bicep — Enable Defender for Cloud plans
// ---------------------------------------------------------------------------
// Enables the Defender plans most relevant to DevOps security demos:
//   - Defender CSPM (for code-to-cloud context)
//   - Defender for Containers (for image vulnerability scanning)
//
// Note: Defender for DevOps itself is configured via the portal connector
// (Environment Settings → DevOps security), not via ARM/Bicep.
// ---------------------------------------------------------------------------

targetScope = 'subscription'

// Defender CSPM
resource defenderCspm 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'CloudPosture'
  properties: {
    pricingTier: 'Standard'
  }
}

// Defender for Containers
resource defenderContainers 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'Containers'
  properties: {
    pricingTier: 'Standard'
  }
}
