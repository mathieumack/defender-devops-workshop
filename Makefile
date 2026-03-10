# ===========================================================================
# Makefile — Defender for DevOps Demo Orchestration
# ===========================================================================
# Commands:
#   make bootstrap      — Create RG, deploy infra, configure scanning
#   make seed-findings  — Commit intentionally vulnerable code/templates
#   make run-scans      — Trigger security scanning workflows
#   make fix            — Apply patches and create a fix PR branch
#   make teardown       — Delete all Azure resources
#   make help           — Show available commands
# ===========================================================================

.PHONY: bootstrap seed-findings run-scans fix teardown help

# Load environment variables
ifneq (,$(wildcard ./variables.env))
    include variables.env
    export
endif

help: ## Show available commands
	@echo ""
	@echo "Defender for DevOps Demo"
	@echo "========================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-18s %s\n", $$1, $$2}'
	@echo ""

bootstrap: ## Create Azure resources and configure scanning prerequisites
	@echo "==> Bootstrapping demo environment..."
	@bash scripts/bootstrap.sh

seed-findings: ## Commit vulnerable code, IaC, and container configs
	@echo "==> Seeding intentional findings..."
	@bash scripts/seed-findings.sh

run-scans: ## Trigger security scanning workflows
	@echo "==> Triggering scans..."
	@bash scripts/run-scans.sh

fix: ## Apply patches and create a fix/remediate-findings branch
	@echo "==> Applying fixes and creating PR branch..."
	@bash scripts/fix.sh

teardown: ## Delete the Azure resource group and all resources
	@echo "==> Tearing down demo environment..."
	@bash scripts/teardown.sh
