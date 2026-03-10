# Option A: Connect GitHub to Defender for Cloud

> **Goal**: Onboard your GitHub organisation so that Defender for Cloud discovers repositories, ingests security findings, and provides unified DevOps posture.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Azure subscription | Defender CSPM plan enabled (or Foundational CSPM at minimum) |
| GitHub organisation | You need **Owner** privileges on the GitHub org |
| Permissions | Azure: at least **Security Admin** on the subscription |

---

## Step-by-Step

### 1. Open the DevOps connector

1. Azure Portal → **Defender for Cloud** → **Environment settings**
2. Click **+ Add environment** → **GitHub**

### 2. Name the connector

- **Connector name**: e.g., `github-lab-connector`
- **Subscription**: Select your Azure subscription
- **Resource group**: Select or create a dedicated RG (e.g., `rg-defender-devops-demo`)
- **Region**: Same region as your other demo resources

### 3. Configure plans

- **DevOps security** (Foundational): Always included
- **CSPM** (if available): Enable for code-to-cloud mapping
- Review pricing and click **Next**

### 4. Authorise GitHub access

1. Click **Authorize** — this opens a GitHub OAuth flow
2. Sign in to GitHub with an identity that has **Owner** access to the target org
3. **Install the Defender for Cloud GitHub App** on the target organisation
4. Select which repositories to monitor:
   - **All repositories** (recommended for lab)
   - Or select specific repos

> **Best practice**: Use a **dedicated service identity** (e.g., a machine account or service principal-backed GitHub App installation) rather than a personal account. All activity performed by the connector (repo discovery, scan results retrieval) is **attributed to this identity in Azure audit logs**.

### 5. Review and create

- Review the summary
- Click **Create**
- Wait for initial discovery (~5-15 minutes for repos to appear)

### 6. Verify

- Go to **Defender for Cloud → DevOps security**
- Confirm your GitHub organisation and repositories appear in the inventory
- After workflows run, verify findings are populated

---

## Important Notes

### One org per tenant

> For **advanced DevOps posture capabilities** (pull request annotations, code-to-cloud mapping, posture policies), Microsoft expects **only one instance of a given GitHub organization** connected per Azure tenant. Connecting the same GitHub org through multiple connectors (e.g., in different subscriptions) can cause **duplicate or missing findings**.

### Minimal permissions

The GitHub App installed by the connector requests:
- **Read** access to code, metadata, and security events
- **Write** access to security events (for PR annotations, if enabled)

Do **not** grant broader admin permissions unless required.

### Removing the connector

1. Azure Portal → Defender for Cloud → Environment settings → select the connector → **Delete**
2. GitHub → Settings → Applications → Installed GitHub Apps → **Revoke** the Defender for Cloud app

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| Repos not appearing | Wait 15 min; check the GitHub App is installed on the correct org |
| No findings showing | Ensure GitHub Advanced Security is enabled; check that workflows ran |
| Duplicate findings | Ensure the org is connected only once per tenant |
| Auth failures | Re-authorise with an account that has Owner access to the GitHub org |
