#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENVIRONMENTS=("dev" "qa" "stage" "prod")
CLOUDS=("aws" "azure" "gcp")
FAILED=()

command -v terraform >/dev/null 2>&1 || {
  printf "%b\n" "${RED}${BOLD}terraform not found in PATH.${RESET}"
  exit 1
}

printf "%b\n" "${BOLD}Running terraform validation across all environment directories...${RESET}"

for env in "${ENVIRONMENTS[@]}"; do
  for cloud in "${CLOUDS[@]}"; do
    dir="$PROJECT_ROOT/environments/$env/$cloud"
    printf "%b\n" "${YELLOW}Checking $env/$cloud${RESET}"
    if (
      cd "$dir"
      terraform fmt -check >/dev/null
      terraform init -backend=false -input=false >/dev/null
      terraform validate >/dev/null
    ); then
      printf "%b\n" "${GREEN}PASS${RESET} $env/$cloud"
    else
      printf "%b\n" "${RED}FAIL${RESET} $env/$cloud"
      FAILED+=("$env/$cloud")
    fi
  done
done

if ((${#FAILED[@]} > 0)); then
  printf "%b\n" "${RED}${BOLD}Validation failures:${RESET} ${FAILED[*]}"
  exit 1
fi

printf "%b\n" "${GREEN}${BOLD}All Terraform directories validated successfully.${RESET}"
