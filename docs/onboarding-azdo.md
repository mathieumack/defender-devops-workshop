# Option B: Connect Azure DevOps to Defender for Cloud

> **Goal**: Onboard your Azure DevOps organisation so that Defender for Cloud discovers repositories, ingests security findings from pipelines, and provides unified DevOps posture.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Azure subscription | Defender CSPM plan enabled (or Foundational CSPM at minimum) |
| Azure DevOps organisation | You need **Project Collection Administrator** privileges |
| Permissions | Azure: at least **Security Admin** on the subscription |

---

## Step-by-Step

### 1. Open the DevOps connector

1. Azure Portal → **Defender for Cloud** → **Environment settings**
2. Click **+ Add environment** → **Azure DevOps**

### 2. Name the connector

- **Connector name**: e.g., `azdo-lab-connector`
- **Subscription**: Select your Azure subscription
- **Resource group**: e.g., `rg-defender-devops-demo`
- **Region**: Same region as your other demo resources

### 3. Configure plans

- **DevOps security** (Foundational): Always included
- **CSPM**: Enable for code-to-cloud mapping
- Review pricing and click **Next**

### 4. Authorise Azure DevOps access

1. Click **Authorize** — this opens an Azure DevOps OAuth flow
2. Sign in with an identity that has **Project Collection Administrator** access
3. Grant the requested permissions

> **Best practice**: Use a **dedicated service identity** (service principal or managed identity) for the connector. All connector activity — repository discovery, pipeline scan result retrieval — is **attributed to this identity in Azure audit logs**. This provides clear auditability and avoids issues if a personal account is deactivated.

### 5. Select organisations and projects

- Choose which Azure DevOps **organisations** to connect
- Within each org, select **all projects** or specific ones
- Click **Next**

### 6. Review and create

- Review the summary
- Click **Create**
- Wait for initial discovery (~5-15 minutes)

### 7. Verify

- Go to **Defender for Cloud → DevOps security**
- Confirm your Azure DevOps organisation and repos appear in the inventory

---

## Setting Up Pipelines with MSDO

When using Azure DevOps pipelines instead of GitHub Actions, install the **Microsoft Security DevOps** extension and add the task to your pipeline:

### Install the extension

1. Azure DevOps → **Organization settings** → **Extensions**
2. Search for **"Microsoft Security DevOps"** in the Visual Studio Marketplace
3. Click **Install** → select your organisation

### Add to pipeline YAML

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - checkout: self

  # Microsoft Security DevOps task
  - task: MicrosoftSecurityDevOps@1
    displayName: 'Run Microsoft Security DevOps'
    inputs:
      # Optionally specify tools: 'checkov,terrascan,trivy,bandit'
      # categories: 'IaC,code,containers'
      break: false   # Don't fail the build (for demo)

  # Publish SARIF results
  - task: PublishBuildArtifacts@1
    displayName: 'Publish SARIF results'
    inputs:
      PathToPublish: '$(System.DefaultWorkingDirectory)/.gdn/msdo.sarif'
      ArtifactName: 'msdo-sarif'
    condition: always()
```

### Service connection approach

For the pipeline to push images to ACR or deploy to Azure:

1. **Azure DevOps → Project settings → Service connections**
2. Create an **Azure Resource Manager** service connection
3. Use **workload identity federation** (recommended) or service principal
4. Scope it to the demo resource group only
5. Reference it in your pipeline:

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'your-service-connection-name'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az acr build --registry $(ACR_NAME) --image demo-api:$(Build.BuildId) -f container/Dockerfile .
```

---

## Important Notes

### Service identity and audit logs

All operations performed by the DevOps connector are attributed to the identity used during authorisation. Use a dedicated service identity for:
- Clear audit trail in Azure Activity Log
- Avoiding disruption if a personal account is disabled
- Easier access reviews and compliance

### Connector identity vs pipeline identity

| Identity | Purpose |
|---|---|
| **Connector identity** | Used by Defender for Cloud to discover repos and ingest findings |
| **Pipeline service connection** | Used by pipelines to authenticate to Azure for deployments |

These can be (and should be) different identities with different permission scopes.

### Minimal permissions for connector

The connector requires:
- Read access to repositories, pipelines, and build results
- Read access to organisation/project metadata

Do **not** grant admin or write permissions to the connector identity.

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| Repos not appearing | Wait 15 min; check Project Collection Administrator access |
| No findings | Ensure MSDO extension is installed and pipelines ran with the task |
| Service connection errors | Verify workload identity federation setup; check subscription scope |
| Connector auth expired | Re-authorise in Defender for Cloud environment settings |
