# Demo Script — Defender for DevOps Talk Track

> **Duration**: ~30 minutes  
> **Audience**: Security teams, DevOps engineers, engineering leaders  
> **Theme**: Unified security visibility from code to cloud

---

## Pre-Demo Checklist

- [ ] Azure subscription with Defender for Cloud enabled
- [ ] DevOps connector configured (GitHub or Azure DevOps)
- [ ] `make bootstrap` completed — Azure resources deployed
- [ ] `make seed-findings` completed — vulnerable code committed
- [ ] `make run-scans` completed — workflow runs finished with findings
- [ ] Browser tabs open:
  - GitHub repo (Security tab)
  - Azure Portal → Defender for Cloud → DevOps security
  - Azure Portal → Defender for Cloud → Recommendations

---

## Section 1: The Problem (2 min)

**Talk track:**

> "Modern applications ship faster than ever. Development teams use open-source dependencies, containerized deployments, and Infrastructure-as-Code — all of which expand the attack surface. Security teams need visibility across all of these vectors, but developers need actionable guidance, not just alerts.
>
> Today I'll show you how Microsoft Defender for Cloud brings these worlds together with **DevOps security** — a single pane of glass that connects your code repositories to your cloud environment."

---

## Section 2: Show GHAS Findings in the Repo (5 min)

### 2.1 Code Scanning (SAST)

1. Navigate to **GitHub repo → Security → Code scanning alerts**
2. Show the SQL injection finding in `app/server.py` (CWE-89)
3. Show the command injection finding (CWE-78)
4. Click into a finding → show the code path, CWE reference, and remediation guidance
5. Point out PR annotation in an open PR (if available)

**Talk track:**

> "CodeQL found two SAST issues — a SQL injection and a command injection. Each alert shows the exact code path, the CWE classification, and suggested fixes. When this runs on a pull request, the developer sees annotations directly on their changed lines."

### 2.2 Secret Scanning

1. Navigate to **Security → Secret scanning alerts**
2. Show the dummy Azure Storage connection string detected in `app/server.py`
3. Note that push protection would have blocked this commit if enabled

**Talk track:**

> "GitHub secret scanning automatically detected a credential pattern in our code. In a real scenario, push protection would block the developer from even committing this. The alert tells us exactly which file and line, and we can revoke and rotate."

### 2.3 Dependency Scanning

1. Navigate to **Security → Dependabot alerts**
2. Show the Flask 2.2.0 CVE (CVE-2023-30861)
3. Show the Dependabot PR that proposes upgrading to a patched version

**Talk track:**

> "Our requirements.txt pins Flask 2.2.0, which has a known session cookie vulnerability. Dependabot not only alerts us but creates a pull request with the fix. This is developer-friendly remediation at its best."

---

## Section 3: Show IaC & Container Findings (5 min)

### 3.1 IaC Misconfiguration

1. Navigate to **Security → Code scanning alerts** (filter by tool: MSDO/Checkov)
2. Show findings from `iac-misconfig/vulnerable.bicep`:
   - Storage account with public blob access
   - NSG allowing all inbound traffic
   - SQL Server with weak password in template
3. Show findings from `iac-misconfig/vulnerable.tf`:
   - HTTP allowed on storage
   - Key Vault without purge protection
   - SSH open to the world

**Talk track:**

> "The Microsoft Security DevOps action ran Checkov and Terrascan against our Bicep and Terraform templates. It found storage accounts exposed to the public internet, NSG rules that are too permissive, and credentials hardcoded in templates. These are caught _before_ anything is deployed."

### 3.2 Container Vulnerabilities

1. Navigate to **Code scanning alerts** (filter by tool: Trivy)
2. Show OS-level CVEs from the `python:3.9-slim` base image
3. Show the Dockerfile running as root

**Talk track:**

> "Trivy scanned our container image at build time, before it ever reaches a registry. It found CVEs in the OS packages of our base image and flagged that the container runs as root — a privilege escalation risk."

---

## Section 4: Defender for Cloud DevOps Security Console (8 min)

### 4.1 DevOps Inventory

1. Open **Azure Portal → Defender for Cloud → DevOps security**
2. Show the connected repository in the inventory view
3. Point out the security posture summary (findings count by severity)

**Talk track:**

> "This is where it comes together for the security team. The DevOps security console shows every connected repository, and for each one, a summary of findings across code, secrets, dependencies, IaC, and containers. One view, all vectors."

### 4.2 Drill-Down

1. Click into the demo repository
2. Show findings grouped by category (Code, Secrets, Dependencies, IaC)
3. Show severity breakdown and trend

**Talk track:**

> "Clicking into a repository shows findings organised by category. Security teams can see severity distribution, track trends over time, and prioritise what to fix first."

### 4.3 Code-to-Cloud Context

1. Navigate to **Defender for Cloud → Recommendations**
2. Show any recommendations related to the deployed Container App or ACR
3. Explain the linkage: "This container image in ACR came from this GitHub repo, and the code that built it has these findings."

**Talk track:**

> "What makes this powerful is _code-to-cloud context_. Defender for Cloud connects the dots — this running container app was built from this repo, using this Dockerfile, with these known vulnerabilities. The security team sees the full picture."

### 4.4 Prioritisation & DevOps Posture

1. Show **Environment Settings → DevOps** for posture policies
2. Show how findings can be assigned to specific teams or developers
3. Show the recommendation to enable branch protection / PR annotations

**Talk track:**

> "From this console, you can set policies — for example, requiring IaC scanning on all PRs, or blocking merges with high-severity findings. You can assign findings to dev teams and track remediation progress."

---

## Section 5: The Fix — Remediation Loop (5 min)

1. Run `make fix` (or show the pre-prepared `fix/remediate-findings` branch)
2. Open the pull request in GitHub
3. Show the changes:
   - `server.py` → `server-fixed.py` (parameterised queries, no hardcoded secrets)
   - `requirements.txt` → `requirements-fixed.txt` (patched Flask)
   - `vulnerable.bicep` → `fixed.bicep` (hardened storage, NSG, SQL)
   - `Dockerfile` → `Dockerfile.fixed` (current base image, non-root user)
4. Show the CI workflows re-running on the PR
5. Show that findings are resolved (green checks, reduced alert count)

**Talk track:**

> "Now let's close the loop. The developer creates a PR with fixes: parameterised SQL queries, patched dependencies, hardened IaC templates, and a secure Dockerfile. The same scanners re-run on the PR and validate that each issue is resolved. The security team sees alert counts drop in Defender for Cloud. This is the developer-friendly security loop."

---

## Section 6: Key Takeaways (2 min)

**Talk track:**

> "Let me summarise what we've seen:
>
> 1. **Shift left**: Find issues in code, dependencies, IaC, and containers _before_ they reach production.
> 2. **Unified visibility**: Security teams get a single console spanning all repos and all security vectors.
> 3. **Developer-friendly**: Findings appear as PR annotations with actionable fixes, not as tickets in a separate system.
> 4. **Code-to-cloud**: Defender for Cloud connects your repo findings to your running workloads, so you see the full risk picture.
> 5. **Automation**: Everything runs in CI/CD — no manual scanning, no context switching."

---

## Teardown

```bash
make teardown
```

This removes:
- The Azure resource group and all resources
- No GitHub-side cleanup needed (repos and findings persist for review)
