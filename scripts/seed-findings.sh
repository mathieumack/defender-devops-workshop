#!/usr/bin/env bash
# ===========================================================================
# scripts/seed-findings.sh — Commit intentionally vulnerable code
# ===========================================================================
# This script stages and commits all the intentionally vulnerable files
# so that security scanners will detect findings on the next workflow run.
#
# If the repository is not yet initialised, it will create the initial commit.
# ===========================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "${REPO_ROOT}"

echo "============================================================"
echo " Defender for DevOps Demo — Seed Findings"
echo "============================================================"

# ── Ensure git is initialised ──────────────────────────────────────────────
if [[ ! -d ".git" ]]; then
    echo "==> Initialising git repository..."
    git init
    git branch -M main
fi

# ── Stage all vulnerable files ─────────────────────────────────────────────
echo "==> Staging vulnerable files..."

git add \
    app/server.py \
    app/requirements.txt \
    iac-misconfig/vulnerable.bicep \
    iac-misconfig/vulnerable.tf \
    container/Dockerfile \
    .github/workflows/ \
    infra/ \
    README.md \
    Makefile \
    docs/ \
    scripts/ \
    variables.env.example

# ── Commit ─────────────────────────────────────────────────────────────────
echo "==> Committing vulnerable code (seed commit)..."
git commit -m "chore: seed intentionally vulnerable code for Defender for DevOps demo

This commit introduces:
- app/server.py: SQL injection, command injection, hardcoded dummy secret, permissive CORS
- app/requirements.txt: Flask 2.2.0 with known CVE-2023-30861
- iac-misconfig/vulnerable.bicep: Public storage, open NSG, weak SQL password
- iac-misconfig/vulnerable.tf: HTTP storage, no purge protection, SSH from anywhere
- container/Dockerfile: Old base image, root user, baked-in dummy secret

All issues are intentional and clearly documented. All secrets are FAKE." \
    --allow-empty

echo ""
echo "============================================================"
echo " Seed commit created."
echo ""
echo " If you have a remote configured, push with:"
echo "   git push origin main"
echo ""
echo " Then run 'make run-scans' to trigger workflows."
echo "============================================================"
