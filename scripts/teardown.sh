#!/usr/bin/env bash
# ===========================================================================
# scripts/teardown.sh — Delete all Azure demo resources
# ===========================================================================
# Deletes the resource group and everything inside it.
# Prompts for confirmation before proceeding.
# ===========================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

if [[ -f "${REPO_ROOT}/variables.env" ]]; then
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/variables.env"
fi

: "${SUBSCRIPTION_ID:?Set SUBSCRIPTION_ID in variables.env}"
: "${RESOURCE_GROUP:?Set RESOURCE_GROUP in variables.env}"

echo "============================================================"
echo " Defender for DevOps Demo — Teardown"
echo "============================================================"
echo ""
echo " This will DELETE the following:"
echo "   Resource Group : ${RESOURCE_GROUP}"
echo "   Subscription   : ${SUBSCRIPTION_ID}"
echo "   All resources within the resource group"
echo ""
read -rp " Are you sure? (y/N): " CONFIRM

if [[ "${CONFIRM}" != "y" && "${CONFIRM}" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "==> Setting subscription..."
az account set --subscription "${SUBSCRIPTION_ID}"

echo "==> Deleting resource group: ${RESOURCE_GROUP}..."
az group delete \
    --name "${RESOURCE_GROUP}" \
    --yes \
    --no-wait

echo ""
echo "============================================================"
echo " Teardown initiated (running in background)."
echo ""
echo " The resource group deletion may take a few minutes."
echo " Monitor with:"
echo "   az group show --name ${RESOURCE_GROUP} --query provisioningState"
echo ""
echo " Note: The DevOps connector in Defender for Cloud is NOT"
echo " removed by this script. To remove it:"
echo "   Azure Portal → Defender for Cloud → Environment settings"
echo "   → Select the connector → Delete"
echo "============================================================"
