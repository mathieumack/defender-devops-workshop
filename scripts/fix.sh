#!/usr/bin/env bash
# ===========================================================================
# scripts/fix.sh — Apply patches and create a remediation PR branch
# ===========================================================================
# Creates a branch 'fix/remediate-findings' with all fixed files,
# ready to open as a pull request to demonstrate the remediation loop.
# ===========================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "${REPO_ROOT}"

BRANCH_NAME="fix/remediate-findings"

echo "============================================================"
echo " Defender for DevOps Demo — Apply Fixes"
echo "============================================================"

# ── Create fix branch ──────────────────────────────────────────────────────
echo "==> Creating branch: ${BRANCH_NAME}"
git checkout -b "${BRANCH_NAME}" 2>/dev/null || git checkout "${BRANCH_NAME}"

# ── Fix 1: Replace vulnerable app code ────────────────────────────────────
echo "==> Applying app code fixes..."
cp "${REPO_ROOT}/app/server-fixed.py" "${REPO_ROOT}/app/server.py"
cp "${REPO_ROOT}/app/requirements-fixed.txt" "${REPO_ROOT}/app/requirements.txt"

# ── Fix 2: Replace vulnerable IaC ─────────────────────────────────────────
echo "==> Applying IaC fixes..."
# Remove the vulnerable templates and keep only the fixed version
cp "${REPO_ROOT}/iac-misconfig/fixed.bicep" "${REPO_ROOT}/iac-misconfig/vulnerable.bicep"

# ── Fix 3: Replace vulnerable Dockerfile ──────────────────────────────────
echo "==> Applying container fixes..."
cp "${REPO_ROOT}/container/Dockerfile.fixed" "${REPO_ROOT}/container/Dockerfile"

# ── Stage and commit ──────────────────────────────────────────────────────
echo "==> Staging and committing fixes..."
git add \
    app/server.py \
    app/requirements.txt \
    iac-misconfig/vulnerable.bicep \
    container/Dockerfile

git commit -m "fix: remediate all security findings

Resolved issues:
- app/server.py: Use parameterised SQL queries (CWE-89), remove command
  injection (CWE-78), remove hardcoded secret, restrict CORS origins,
  disable debug mode
- app/requirements.txt: Upgrade Flask to 3.1.0 (fixes CVE-2023-30861),
  upgrade all dependencies to latest patched versions
- iac-misconfig/vulnerable.bicep: Disable public blob access, enforce
  HTTPS-only, require TLS 1.2, restrict NSG rules, remove hardcoded
  password (use @secure param)
- container/Dockerfile: Use python:3.12-slim base, run as non-root user,
  remove baked-in secrets, use patched dependencies"

echo ""
echo "============================================================"
echo " Fix branch '${BRANCH_NAME}' created with remediation commit."
echo ""
echo " To push and create a PR:"
echo "   git push origin ${BRANCH_NAME}"
echo ""
echo " GitHub CLI shortcut:"
echo "   gh pr create --title 'fix: remediate all security findings' \\"
echo "     --body 'Resolves SAST, dependency, IaC, and container findings.' \\"
echo "     --base main --head ${BRANCH_NAME}"
echo ""
echo " Then watch the CI workflows re-run on the PR to show"
echo " findings resolved."
echo "============================================================"
