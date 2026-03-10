#!/usr/bin/env bash
# ===========================================================================
# scripts/bootstrap.sh — Create Azure resources & configure scanning
# ===========================================================================
# Prerequisites:
#   - Azure CLI logged in (az login)
#   - variables.env sourced (or environment variables set)
# ===========================================================================
set -euo pipefail

# ── Load variables ──────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

if [[ -f "${REPO_ROOT}/variables.env" ]]; then
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/variables.env"
fi

: "${SUBSCRIPTION_ID:?Set SUBSCRIPTION_ID in variables.env}"
: "${LOCATION:?Set LOCATION in variables.env}"
: "${RESOURCE_GROUP:?Set RESOURCE_GROUP in variables.env}"
: "${ACR_NAME:?Set ACR_NAME in variables.env}"
: "${APP_NAME:=demo-api}"

echo "============================================================"
echo " Defender for DevOps Demo — Bootstrap"
echo "============================================================"
echo " Subscription : ${SUBSCRIPTION_ID}"
echo " Location     : ${LOCATION}"
echo " Resource Group: ${RESOURCE_GROUP}"
echo " ACR          : ${ACR_NAME}"
echo " App          : ${APP_NAME}"
echo "============================================================"

# ── Set subscription ────────────────────────────────────────────────────────
echo ""
echo "==> Setting subscription..."
az account set --subscription "${SUBSCRIPTION_ID}"

# ── Deploy Bicep (subscription-level deployment) ───────────────────────────
echo ""
echo "==> Deploying infrastructure (Bicep)..."
az deployment sub create \
    --location "${LOCATION}" \
    --template-file "${REPO_ROOT}/infra/main.bicep" \
    --parameters \
        location="${LOCATION}" \
        resourceGroupName="${RESOURCE_GROUP}" \
        acrName="${ACR_NAME}" \
        appName="${APP_NAME}" \
        enableDefender=true \
    --name "defender-devops-demo-$(date +%Y%m%d%H%M%S)"

# ── Build and push container image to ACR ──────────────────────────────────
echo ""
echo "==> Building container image in ACR..."
az acr build \
    --registry "${ACR_NAME}" \
    --image "${APP_NAME}:latest" \
    --file "${REPO_ROOT}/container/Dockerfile" \
    "${REPO_ROOT}"

# ── Update Container App with the built image ─────────────────────────────
echo ""
echo "==> Updating Container App with new image..."
az containerapp update \
    --name "${APP_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --image "${ACR_NAME}.azurecr.io/${APP_NAME}:latest" \
    2>/dev/null || echo "  (Container App update skipped — may need manual image config)"

# ── Enable Defender for Cloud plans (if not already via Bicep) ─────────────
echo ""
echo "==> Ensuring Defender plans are enabled..."
az security pricing create --name "CloudPosture" --tier "Standard" 2>/dev/null || true
az security pricing create --name "Containers" --tier "Standard" 2>/dev/null || true

echo ""
echo "============================================================"
echo " Bootstrap complete!"
echo ""
echo " Next steps:"
echo "   1. Connect your DevOps org in Defender for Cloud"
echo "      (see docs/onboarding-github.md or docs/onboarding-azdo.md)"
echo "   2. Run 'make seed-findings' to commit vulnerable code"
echo "   3. Run 'make run-scans' to trigger scanning workflows"
echo "============================================================"
