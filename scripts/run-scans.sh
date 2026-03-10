#!/usr/bin/env bash
# ===========================================================================
# scripts/run-scans.sh — Trigger security scanning workflows
# ===========================================================================
# For GitHub: pushes to main to trigger on-push workflows, or uses
# the GitHub CLI to manually dispatch workflows.
#
# For Azure DevOps: triggers a pipeline run via az pipelines CLI.
# ===========================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "${REPO_ROOT}"

echo "============================================================"
echo " Defender for DevOps Demo — Run Scans"
echo "============================================================"

# ── Detect platform ────────────────────────────────────────────────────────
if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    PLATFORM="github"
elif command -v az &>/dev/null && az devops project list &>/dev/null 2>&1; then
    PLATFORM="azdo"
else
    PLATFORM="manual"
fi

echo "==> Detected platform: ${PLATFORM}"
echo ""

case "${PLATFORM}" in
    github)
        echo "==> Pushing to main to trigger on-push workflows..."
        git push origin main 2>/dev/null || echo "  (Push failed — ensure remote is configured)"

        echo ""
        echo "==> Manually dispatching workflows (if supported)..."
        gh workflow run codeql.yml 2>/dev/null || echo "  CodeQL workflow dispatch not available (runs on push)"
        gh workflow run msdo.yml 2>/dev/null || echo "  MSDO workflow dispatch not available (runs on push)"
        gh workflow run container-scan.yml 2>/dev/null || echo "  Container scan dispatch not available (runs on push)"
        gh workflow run secret-scan-notes.yml 2>/dev/null || true

        echo ""
        echo "==> Listing recent workflow runs..."
        gh run list --limit 5
        ;;

    azdo)
        echo "==> Triggering Azure DevOps pipeline..."
        # Adjust pipeline name as needed
        az pipelines run --name "defender-devops-demo" 2>/dev/null || \
            echo "  Pipeline not found. Create it from azure-pipelines.yml first."
        ;;

    manual)
        echo "==> No CLI detected. To trigger scans manually:"
        echo ""
        echo "  GitHub:"
        echo "    1. Push the seed commit: git push origin main"
        echo "    2. Go to Actions tab and verify workflow runs started"
        echo ""
        echo "  Azure DevOps:"
        echo "    1. Push to the repo"
        echo "    2. Go to Pipelines and trigger a run"
        ;;
esac

echo ""
echo "============================================================"
echo " Scans triggered. It may take 5-15 minutes for results to"
echo " appear in the Security tab and Defender for Cloud console."
echo "============================================================"
