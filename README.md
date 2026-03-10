# Defender for DevOps — End-to-End Demo Environment

> **Purpose**: A self-contained, repeatable demo that showcases **DevOps security in Microsoft Defender for Cloud** with real findings across code, secrets, dependencies, IaC, and containers — plus unified visibility for security teams and actionable remediation for developers.

---

## Repository Layout

```
.
├── README.md                       ← You are here
├── Makefile                        ← Orchestration commands
├── variables.env.example           ← Template for required variables
├── scripts/
│   ├── bootstrap.sh                ← Create RG, deploy infra, configure scanning
│   ├── seed-findings.sh            ← Commit vulnerable code/templates
│   ├── run-scans.sh                ← Trigger workflows/pipelines
│   ├── fix.sh                      ← Apply patches, create PR branch
│   └── teardown.sh                 ← Clean up all Azure resources
├── infra/
│   ├── main.bicep                  ← Resource Group + workload (Container Apps)
│   ├── modules/
│   │   ├── container-app.bicep     ← Container Apps environment + app
│   │   ├── acr.bicep               ← Azure Container Registry
│   │   ├── log-analytics.bicep     ← Log Analytics workspace
│   │   └── defender.bicep          ← Defender for Cloud plans
│   └── parameters.json            ← Deployment parameters
├── app/
│   ├── server.py                   ← Vulnerable Flask API (SAST + config issues)
│   ├── requirements.txt            ← Pinned vulnerable dependency
│   ├── requirements-fixed.txt      ← Patched dependency versions
│   └── server-fixed.py            ← Remediated Flask API
├── iac-misconfig/
│   ├── vulnerable.bicep            ← Intentionally misconfigured IaC
│   ├── fixed.bicep                 ← Remediated IaC
│   └── vulnerable.tf              ← Terraform misconfiguration example
├── container/
│   ├── Dockerfile                  ← Vulnerable container image
│   └── Dockerfile.fixed           ← Remediated container image
├── .github/
│   └── workflows/
│       ├── codeql.yml              ← CodeQL SAST scanning
│       ├── dependency-review.yml   ← Dependency review on PRs
│       ├── msdo.yml                ← Microsoft Security DevOps (IaC + more)
│       ├── container-scan.yml      ← Container image vulnerability scan
│       └── secret-scan-notes.yml   ← Secret scanning guidance
└── docs/
    ├── demo-script.md              ← Talk track / demo runbook
    ├── onboarding-github.md        ← Option A: Connect GitHub to Defender
    └── onboarding-azdo.md          ← Option B: Connect Azure DevOps to Defender
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| **Azure subscription** | With permissions to create RGs, enable Defender plans |
| **Azure CLI** ≥ 2.50 | `az --version` |
| **GitHub org or Azure DevOps org** | To connect via DevOps connector |
| **GitHub repo** (if Option A) | With GitHub Advanced Security (GHAS) enabled |
| **Docker** | For local container builds |
| **Python 3.10+** | For the demo app |
| **Make** (optional) | Or run scripts directly |

---

## Quick Start

### 1. Clone and configure

```bash
cp variables.env.example variables.env
# Edit variables.env with your values
source variables.env
```

### 2. Bootstrap Azure infrastructure

```bash
make bootstrap
# Or: bash scripts/bootstrap.sh
```

This creates:
- A dedicated resource group
- Azure Container Registry (ACR)
- Container Apps environment + a minimal app
- Log Analytics workspace
- Enables Defender for Cloud plans (Containers, CSPM)

### 3. Seed intentionally vulnerable findings

```bash
make seed-findings
# Or: bash scripts/seed-findings.sh
```

Commits the vulnerable app code, IaC templates, and container definitions so scanners will detect issues.

### 4. Run security scans

```bash
make run-scans
# Or: bash scripts/run-scans.sh
```

Triggers GitHub Actions workflows (or Azure Pipelines) that produce SARIF results and PR annotations.

### 5. Demonstrate in Defender for Cloud

Open the Azure Portal → **Defender for Cloud** → **DevOps security** to see:
- Inventory of connected repos
- Posture assessment across code, secrets, dependencies, IaC, containers
- Drill-down into individual findings
- Code-to-cloud context (deployed workload linked to repo)

### 6. Show the fix

```bash
make fix
# Or: bash scripts/fix.sh
```

Creates a `fix/remediate-findings` branch with patched code, dependencies, IaC, and Dockerfile, then pushes for a PR.

### 7. Teardown

```bash
make teardown
# Or: bash scripts/teardown.sh
```

Deletes the resource group and all contained resources.

---

## Onboarding Defender for DevOps

See detailed instructions for each platform:

- **[Option A: GitHub](docs/onboarding-github.md)** — Connect your GitHub organization
- **[Option B: Azure DevOps](docs/onboarding-azdo.md)** — Connect your Azure DevOps organization

### Key architectural notes

1. **Service identity**: Use a dedicated service principal or managed identity for the DevOps connector. All connector activity (repo discovery, scan orchestration) is attributed to this identity in Azure audit logs.
2. **Minimal permissions**: The connector needs read access to repos and the ability to write security findings. Do not grant broader admin permissions.
3. **One org per tenant**: For advanced DevOps posture capabilities (e.g., pull request annotations, code-to-cloud mapping), Microsoft expects only **one instance** of a GitHub org connected per Azure tenant connector. Connecting the same org through multiple connectors can cause duplicate or missing findings.

---

## Variables Reference

| Variable | Description | Example |
|---|---|---|
| `SUBSCRIPTION_ID` | Azure subscription ID | `00000000-0000-0000-0000-000000000000` |
| `TENANT_ID` | Azure AD tenant ID | `00000000-0000-0000-0000-000000000000` |
| `LOCATION` | Azure region | `eastus` |
| `RESOURCE_GROUP` | Resource group name | `rg-defender-devops-demo` |
| `ACR_NAME` | Container registry name (globally unique) | `acrdefdevopsdemo` |
| `APP_NAME` | Container app name | `demo-api` |
| `REPO_NAME` | GitHub or Azure DevOps repo name | `defender-devops-workshop` |

---

## Safety Notice

> **All secrets in this repo are intentionally fake/dummy values** used solely to trigger secret-scanning alerts. They are clearly marked and have no access to any real system. Do not replace them with real credentials.

---

## License

MIT — for demo/lab purposes only. Not intended for production use.
