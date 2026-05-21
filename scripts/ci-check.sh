#!/usr/bin/env bash
# CI check script — runs fmt, validate, tfsec, checkov
set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

PASS=0
FAIL=0
SKIP=0

run_check() {
  local name="$1"
  local cmd="$2"
  printf "${YELLOW}==> ${name}...${RESET}\n"
  if eval "$cmd" 2>&1; then
    printf "${GREEN}✅ ${name} passed${RESET}\n\n"
    PASS=$((PASS+1))
  else
    printf "${RED}❌ ${name} FAILED${RESET}\n\n"
    FAIL=$((FAIL+1))
  fi
}

skip_check() {
  local name="$1"
  local reason="$2"
  printf "${YELLOW}⏭️  ${name} skipped: ${reason}${RESET}\n\n"
  SKIP=$((SKIP+1))
}

# 1. Format check
run_check "Terraform Format" "terraform fmt -check -recursive ."

# 2. Validate all envs
run_check "Terraform Validate" "bash scripts/validate.sh"

# 3. tfsec
if command -v tfsec &>/dev/null; then
  run_check "tfsec Security" "tfsec . --minimum-severity MEDIUM --no-color"
else
  skip_check "tfsec" "not installed (brew install tfsec OR go install github.com/aquasecurity/tfsec/cmd/tfsec@latest)"
fi

# 4. checkov
if command -v checkov &>/dev/null; then
  run_check "Checkov" "checkov -d . --framework terraform --quiet --compact"
else
  skip_check "Checkov" "not installed (pip3 install checkov)"
fi

printf "\n${BOLD:-}Results: ${GREEN}${PASS} passed${RESET}, ${RED}${FAIL} failed${RESET}, ${YELLOW}${SKIP} skipped${RESET}\n"
[[ $FAIL -eq 0 ]]
