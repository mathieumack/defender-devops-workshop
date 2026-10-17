#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${REPO_ROOT}/.venv"

python3 -m venv "${VENV_DIR}"
"${VENV_DIR}/bin/python" -m pip install --upgrade pip
"${VENV_DIR}/bin/python" -m pip install -r "${REPO_ROOT}/app/requirements.txt"

if command -v az >/dev/null 2>&1; then
    az config set extension.use_dynamic_install=yes_without_prompt
    az bicep install || az bicep version >/dev/null 2>&1 || echo "Warning: unable to install Bicep automatically." >&2
    az extension add --name azure-devops --upgrade || echo "Warning: unable to install the azure-devops extension automatically." >&2
    az extension add --name containerapp --upgrade || echo "Warning: unable to install the containerapp extension automatically." >&2
fi
