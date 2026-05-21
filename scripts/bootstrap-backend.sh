#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENVIRONMENTS=(dev qa stage prod)
CLOUDS=(aws azure gcp)
SELECTED_CLOUDS=()
PARSED_SELECTION=()
AWS_REGION=""
AWS_BUCKET=""
AWS_TABLE=""
AZURE_RG=""
AZURE_LOCATION=""
AZURE_STORAGE_ACCOUNT=""
AZURE_CONTAINER="tfstate"
GCP_PROJECT_ID=""
GCP_BUCKET=""
GCP_LOCATION=""

log() {
  printf "%b\n" "$1"
}

die() {
  log "${RED}${BOLD}Error:${RESET} $1"
  exit 1
}

banner() {
  log "${CYAN}${BOLD}"
  log "╔══════════════════════════════════════════════╗"
  log "║      Terraform Multi-Cloud Deployment       ║"
  log "╚══════════════════════════════════════════════╝"
  log "${RESET}"
}

parse_multi_select() {
  local input="$1"
  shift
  local options=("$@")
  local normalized="${input//,/ }"
  local tokens=()
  local token value seen=" "
  PARSED_SELECTION=()

  [ -n "${normalized//[[:space:]]/}" ] || return 1
  read -r -a tokens <<< "$normalized"

  for token in "${tokens[@]}"; do
    [[ "$token" =~ ^[0-9]+$ ]] || return 1
    [ "$token" -ge 1 ] && [ "$token" -le "${#options[@]}" ] || return 1
    value="${options[$((token - 1))]}"
    case "$seen" in
      *" $value "*) ;;
      *) PARSED_SELECTION+=("$value"); seen="$seen$value " ;;
    esac
  done

  [ "${#PARSED_SELECTION[@]}" -gt 0 ] || return 1
}

prompt_clouds() {
  local input i
  while true; do
    log "${BOLD}Select clouds to bootstrap remote state for${RESET}"
    for ((i=0; i<${#CLOUDS[@]}; i++)); do
      log "  $((i + 1))) ${CLOUDS[$i]}"
    done
    printf "%b" "${YELLOW}Enter numbers separated by spaces or commas:${RESET} "
    read -r input
    if parse_multi_select "$input" "${CLOUDS[@]}"; then
      SELECTED_CLOUDS=("${PARSED_SELECTION[@]}")
      break
    fi
    log "${RED}Invalid selection. Choose at least one valid option.${RESET}"
  done
}

ensure_command() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required for this bootstrap action."
}

prompt_aws() {
  ensure_command aws
  printf "%b" "${YELLOW}AWS region [us-east-1]:${RESET} "
  read -r AWS_REGION
  AWS_REGION="${AWS_REGION:-us-east-1}"
  printf "%b" "${YELLOW}Unique suffix for the state bucket:${RESET} "
  read -r suffix
  [ -n "$suffix" ] || die "A unique suffix is required for the AWS bucket."
  AWS_BUCKET="terraform-multicloud-state-${suffix}"
  AWS_TABLE="terraform-multicloud-locks-${suffix}"

  if [ "$AWS_REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$AWS_BUCKET" --region "$AWS_REGION"
  else
    aws s3api create-bucket --bucket "$AWS_BUCKET" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
  aws s3api put-bucket-versioning --bucket "$AWS_BUCKET" --versioning-configuration Status=Enabled
  aws s3api put-bucket-encryption --bucket "$AWS_BUCKET" --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
  aws s3api put-public-access-block --bucket "$AWS_BUCKET" --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
  aws dynamodb create-table \
    --table-name "$AWS_TABLE" \
    --billing-mode PAY_PER_REQUEST \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH >/dev/null
}

prompt_azure() {
  ensure_command az
  printf "%b" "${YELLOW}Azure backend resource group name:${RESET} "
  read -r AZURE_RG
  [ -n "$AZURE_RG" ] || die "Azure resource group name is required."
  printf "%b" "${YELLOW}Azure location [eastus]:${RESET} "
  read -r AZURE_LOCATION
  AZURE_LOCATION="${AZURE_LOCATION:-eastus}"
  printf "%b" "${YELLOW}Azure storage account name (3-24 lowercase letters/numbers):${RESET} "
  read -r AZURE_STORAGE_ACCOUNT
  [ -n "$AZURE_STORAGE_ACCOUNT" ] || die "Azure storage account name is required."

  az group create --name "$AZURE_RG" --location "$AZURE_LOCATION" >/dev/null
  az storage account create --name "$AZURE_STORAGE_ACCOUNT" --resource-group "$AZURE_RG" --location "$AZURE_LOCATION" --sku Standard_LRS --encryption-services blob >/dev/null
  az storage container create --name "$AZURE_CONTAINER" --account-name "$AZURE_STORAGE_ACCOUNT" --auth-mode login >/dev/null
}

prompt_gcp() {
  ensure_command gsutil
  printf "%b" "${YELLOW}GCP project ID:${RESET} "
  read -r GCP_PROJECT_ID
  [ -n "$GCP_PROJECT_ID" ] || die "GCP project ID is required."
  printf "%b" "${YELLOW}GCS bucket name:${RESET} "
  read -r GCP_BUCKET
  [ -n "$GCP_BUCKET" ] || die "GCS bucket name is required."
  printf "%b" "${YELLOW}GCS location [US]:${RESET} "
  read -r GCP_LOCATION
  GCP_LOCATION="${GCP_LOCATION:-US}"

  gsutil mb -p "$GCP_PROJECT_ID" -l "$GCP_LOCATION" "gs://$GCP_BUCKET"
  gsutil versioning set on "gs://$GCP_BUCKET"
}

show_snippets() {
  local cloud
  for cloud in "${SELECTED_CLOUDS[@]}"; do
    case "$cloud" in
      aws)
        log "${GREEN}${BOLD}AWS backend snippet${RESET}"
        cat <<SNIPPET
terraform {
  backend "s3" {
    bucket         = "$AWS_BUCKET"
    key            = "ENV/aws/terraform.tfstate"
    region         = "$AWS_REGION"
    dynamodb_table = "$AWS_TABLE"
    encrypt        = true
  }
}
SNIPPET
        ;;
      azure)
        log "${GREEN}${BOLD}Azure backend snippet${RESET}"
        cat <<SNIPPET
terraform {
  backend "azurerm" {
    resource_group_name  = "$AZURE_RG"
    storage_account_name = "$AZURE_STORAGE_ACCOUNT"
    container_name       = "$AZURE_CONTAINER"
    key                  = "ENV/azure/terraform.tfstate"
  }
}
SNIPPET
        ;;
      gcp)
        log "${GREEN}${BOLD}GCP backend snippet${RESET}"
        cat <<SNIPPET
terraform {
  backend "gcs" {
    bucket = "$GCP_BUCKET"
    prefix = "ENV/gcp/terraform.tfstate"
  }
}
SNIPPET
        ;;
    esac
    log ""
  done
}

update_backend_files() {
  local cloud env path
  for cloud in "${SELECTED_CLOUDS[@]}"; do
    for env in "${ENVIRONMENTS[@]}"; do
      path="$PROJECT_ROOT/environments/$env/$cloud/backend.tf"
      case "$cloud" in
        aws)
          cat > "$path" <<BACKEND
terraform {
  backend "s3" {
    bucket         = "$AWS_BUCKET"
    key            = "$env/aws/terraform.tfstate"
    region         = "$AWS_REGION"
    dynamodb_table = "$AWS_TABLE"
    encrypt        = true
  }
}
BACKEND
          ;;
        azure)
          cat > "$path" <<BACKEND
terraform {
  backend "azurerm" {
    resource_group_name  = "$AZURE_RG"
    storage_account_name = "$AZURE_STORAGE_ACCOUNT"
    container_name       = "$AZURE_CONTAINER"
    key                  = "$env/azure/terraform.tfstate"
  }
}
BACKEND
          ;;
        gcp)
          cat > "$path" <<BACKEND
terraform {
  backend "gcs" {
    bucket = "$GCP_BUCKET"
    prefix = "$env/gcp/terraform.tfstate"
  }
}
BACKEND
          ;;
      esac
    done
  done
}

main() {
  local cloud update_choice
  banner
  prompt_clouds
  for cloud in "${SELECTED_CLOUDS[@]}"; do
    case "$cloud" in
      aws) prompt_aws ;;
      azure) prompt_azure ;;
      gcp) prompt_gcp ;;
    esac
  done
  show_snippets
  printf "%b" "${YELLOW}Auto-update all matching backend.tf files with these values? [y/N]:${RESET} "
  read -r update_choice
  case "$update_choice" in
    y|Y|yes|YES|Yes)
      update_backend_files
      log "${GREEN}Updated backend.tf files for: $(printf '%s ' "${SELECTED_CLOUDS[@]}")${RESET}"
      ;;
    *)
      log "${YELLOW}Skipped backend.tf updates. Use the snippets above or backend-configs/ templates.${RESET}"
      ;;
  esac
}

main "$@"
