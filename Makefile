SHELL := /bin/bash
.DEFAULT_GOAL := help

TERRAFORM_DIRS := $(shell find environments -name "*.tf" -exec dirname {} \; | sort -u)
VERSION_FILE   := versions/VERSION
CURRENT_VERSION := $(shell cat $(VERSION_FILE) 2>/dev/null || echo "1.0.2")

.PHONY: help deploy destroy validate fmt-check fmt-fix lint tfsec checkov sonar \
        pre-commit-install pre-commit-run tag-patch tag-minor tag-major \
        tag-show clean docs all-checks bootstrap

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' | sort

deploy:  ## Interactive deploy (runs scripts/deploy.sh)
	@bash scripts/deploy.sh

destroy:  ## Interactive destroy (runs scripts/destroy.sh)
	@bash scripts/destroy.sh

validate:  ## Validate all Terraform environments
	@bash scripts/validate.sh

fmt-check:  ## Check Terraform formatting (no changes)
	@echo "==> Checking Terraform formatting..."
	@terraform fmt -check -recursive . && echo "✅ All files formatted correctly" || \
	  (echo "❌ Formatting issues found. Run: make fmt-fix" && exit 1)

fmt-fix:  ## Fix Terraform formatting
	@echo "==> Fixing Terraform formatting..."
	@terraform fmt -recursive .
	@echo "✅ Formatting applied"

lint: fmt-check validate  ## Run fmt-check + validate

tfsec:  ## Run tfsec security scanner
	@echo "==> Running tfsec..."
	@command -v tfsec >/dev/null 2>&1 || (echo "Installing tfsec..." && \
	  curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash)
	@tfsec . --minimum-severity MEDIUM --no-color || true

checkov:  ## Run Checkov IaC security scan
	@echo "==> Running Checkov..."
	@command -v checkov >/dev/null 2>&1 || pip3 install checkov -q
	@checkov -d . --framework terraform --quiet --compact || true

sonar:  ## Run SonarQube analysis (requires SONAR_TOKEN env var)
	@echo "==> Running SonarQube analysis..."
	@test -n "$$SONAR_TOKEN" || (echo "❌ SONAR_TOKEN env var required" && exit 1)
	@command -v sonar-scanner >/dev/null 2>&1 || \
	  (echo "sonar-scanner not found. Install from: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/" && exit 1)
	@sonar-scanner -Dsonar.login=$$SONAR_TOKEN

pre-commit-install:  ## Install pre-commit hooks
	@command -v pre-commit >/dev/null 2>&1 || pip3 install pre-commit -q
	@pre-commit install
	@echo "✅ pre-commit hooks installed"

pre-commit-run:  ## Run all pre-commit hooks on all files
	@pre-commit run --all-files

all-checks:  ## Run all checks (fmt + validate + tfsec + checkov)
	@bash scripts/ci-check.sh

tag-show:  ## Show current version and all tags
	@echo "Current version: $(CURRENT_VERSION)"
	@echo "All tags:"
	@git tag -l | sort -V

tag-patch:  ## Bump patch version (1.0.2 → 1.0.3)
	@bash scripts/bump-version.sh patch

tag-minor:  ## Bump minor version (1.0.2 → 1.1.0)
	@bash scripts/bump-version.sh minor

tag-major:  ## Bump major version (1.0.2 → 2.0.0)
	@bash scripts/bump-version.sh major

bootstrap:  ## Bootstrap remote state backends
	@bash scripts/bootstrap-backend.sh

docs:  ## Generate terraform-docs (requires terraform-docs installed)
	@command -v terraform-docs >/dev/null 2>&1 || \
	  (echo "terraform-docs not found. Install: https://terraform-docs.io/user-guide/installation/" && exit 1)
	@find modules -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do \
	  terraform-docs markdown table --output-file README.md --output-mode inject "$$dir" 2>/dev/null || true; \
	done
	@echo "✅ Module docs updated"

clean:  ## Remove .terraform dirs and log files
	@echo "==> Cleaning .terraform directories..."
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@rm -f logs/*.log
	@echo "✅ Clean complete"
