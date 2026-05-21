#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/deploy_$(date +%Y%m%d_%H%M%S).log"

ENVIRONMENTS=(dev qa stage prod)
CLOUDS=(aws azure gcp)
ACTIONS=(plan apply destroy)
SELECTED_ENVS=()
SELECTED_CLOUDS=()
PARSED_SELECTION=()
FAILED_COMBINATIONS=()
ACTION=""
COMPUTE_MODE="vm"
DB_ENGINE_CHOICE="postgresql"
NODE_COUNT=2

log() {
  printf "%b\n" "$1" | tee -a "$LOG_FILE"
}

die() {
  log "${RED}${BOLD}Error:${RESET} $1"
  exit 1
}

on_error() {
  local exit_code=$?
  log "${RED}${BOLD}Execution aborted.${RESET} Review log: $LOG_FILE"
  exit "$exit_code"
}
trap on_error ERR

banner() {
  log "${CYAN}${BOLD}"
  log "╔══════════════════════════════════════════════╗"
  log "║      Terraform Multi-Cloud Deployment       ║"
  log "╚══════════════════════════════════════════════╝"
  log "${RESET}"
}

join_by() {
  local delimiter="$1"
  shift
  local first=1
  local item
  for item in "$@"; do
    if [ "$first" -eq 1 ]; then
      printf "%s" "$item"
      first=0
    else
      printf "%s%s" "$delimiter" "$item"
    fi
  done
}

default_vm_count() {
  case "$1" in
    dev) echo 1 ;;
    qa) echo 2 ;;
    stage) echo 3 ;;
    prod) echo 5 ;;
    *) die "Unknown environment '$1'" ;;
  esac
}

set_vm_count() {
  eval "VM_COUNT_$1=$2"
}

get_vm_count() {
  if eval "[ \"\${VM_COUNT_$1+x}\" = x ]"; then
    eval "printf '%s' \"\${VM_COUNT_$1}\""
  else
    default_vm_count "$1"
  fi
}

check_dependencies() {
  command -v terraform >/dev/null 2>&1 || die "terraform not found in PATH. Install Terraform >= 1.5.0 first."
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
      *)
        PARSED_SELECTION+=("$value")
        seen="$seen$value "
        ;;
    esac
  done

  [ "${#PARSED_SELECTION[@]}" -gt 0 ] || return 1
}

prompt_multi_select() {
  local target="$1"
  local title="$2"
  shift 2
  local options=("$@")
  local input i

  while true; do
    log "${BOLD}${title}${RESET}"
    for ((i=0; i<${#options[@]}; i++)); do
      log "  $((i + 1))) ${options[$i]}"
    done
    printf "%b" "${YELLOW}Enter numbers separated by spaces or commas:${RESET} "
    read -r input
    if parse_multi_select "$input" "${options[@]}"; then
      if [ "$target" = "SELECTED_ENVS" ]; then
        SELECTED_ENVS=("${PARSED_SELECTION[@]}")
      else
        SELECTED_CLOUDS=("${PARSED_SELECTION[@]}")
      fi
      break
    fi
    log "${RED}Invalid selection. Choose at least one valid option.${RESET}"
  done
}

prompt_single_choice() {
  local __resultvar="$1"
  local title="$2"
  shift 2
  local options=("$@")
  local input i

  while true; do
    log "${BOLD}${title}${RESET}"
    for ((i=0; i<${#options[@]}; i++)); do
      log "  $((i + 1))) ${options[$i]}"
    done
    printf "%b" "${YELLOW}Choose one option:${RESET} "
    read -r input
    [[ "$input" =~ ^[0-9]+$ ]] || { log "${RED}Invalid selection.${RESET}"; continue; }
    [ "$input" -ge 1 ] && [ "$input" -le "${#options[@]}" ] || { log "${RED}Invalid selection.${RESET}"; continue; }
    printf -v "$__resultvar" '%s' "${options[$((input - 1))]}"
    break
  done
}

prompt_action() {
  prompt_single_choice ACTION "Select action" "${ACTIONS[@]}"
}

validate_count() {
  local value="$1"
  [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -ge 1 ] && [ "$value" -le 50 ]
}

prompt_vm_counts() {
  local env input default_count

  log "${BOLD}Default VM counts${RESET}"
  for env in "${SELECTED_ENVS[@]}"; do
    default_count="$(default_vm_count "$env")"
    set_vm_count "$env" "$default_count"
    log "  - $env=$default_count"
  done

  printf "%b" "${YELLOW}Override VM count per selected environment? [y/N]:${RESET} "
  read -r input
  case "$input" in
    y|Y|yes|YES|Yes) ;;
    *) return ;;
  esac

  for env in "${SELECTED_ENVS[@]}"; do
    default_count="$(default_vm_count "$env")"
    while true; do
      printf "%b" "${YELLOW}VM count for $env (1-50, Enter for default $default_count):${RESET} "
      read -r input
      if [ -z "$input" ]; then
        set_vm_count "$env" "$default_count"
        break
      fi
      if validate_count "$input"; then
        set_vm_count "$env" "$input"
        break
      fi
      log "${RED}VM count must be a number from 1 to 50.${RESET}"
    done
  done
}

prompt_node_count() {
  local input
  while true; do
    printf "%b" "${YELLOW}Kubernetes node count (1-50, Enter for default 2):${RESET} "
    read -r input
    if [ -z "$input" ]; then
      NODE_COUNT=2
      break
    fi
    if validate_count "$input"; then
      NODE_COUNT="$input"
      break
    fi
    log "${RED}Node count must be a number from 1 to 50.${RESET}"
  done
}

cloud_db_engine() {
  local cloud="$1"
  case "$DB_ENGINE_CHOICE" in
    postgresql) echo "postgresql" ;;
    mysql) echo "mysql" ;;
    sqlserver)
      case "$cloud" in
        aws) echo "sqlserver-se" ;;
        *) echo "sqlserver" ;;
      esac
      ;;
    aurora-postgresql) echo "aurora-postgresql" ;;
    aurora-mysql) echo "aurora-mysql" ;;
    *) die "Unsupported database engine selection: $DB_ENGINE_CHOICE" ;;
  esac
}

validate_engine_clouds() {
  local cloud
  if [[ "$DB_ENGINE_CHOICE" == aurora-* ]]; then
    for cloud in "${SELECTED_CLOUDS[@]}"; do
      [ "$cloud" = "aws" ] || die "Aurora engines are supported only for AWS deployments."
    done
  fi
}

show_summary() {
  local env vm_items=()
  for env in "${SELECTED_ENVS[@]}"; do
    vm_items+=("$env=$(get_vm_count "$env")")
  done

  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "  Deployment Plan"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "  Environments : $(join_by ', ' "${SELECTED_ENVS[@]}")"
  log "  Clouds       : $(join_by ', ' "${SELECTED_CLOUDS[@]}")"
  log "  Action       : $ACTION"
  log "  Compute      : $COMPUTE_MODE"
  log "  DB Engine    : $DB_ENGINE_CHOICE"
  if [ "$COMPUTE_MODE" != "kubernetes" ]; then
    log "  VM Count     : $(join_by ', ' "${vm_items[@]}")"
  fi
  if [ "$COMPUTE_MODE" != "vm" ]; then
    log "  Node Count   : $NODE_COUNT"
  fi
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

run_terraform() {
  local env="$1"
  local cloud="$2"
  local dir="$PROJECT_ROOT/environments/$env/$cloud"
  local vm_count="$(get_vm_count "$env")"
  local db_engine
  local compute_type="vm"
  local use_kubernetes="false"
  local args=()

  if [ ! -d "$dir" ]; then
    FAILED_COMBINATIONS+=("$env/$cloud")
    log "${RED}Missing directory: $dir${RESET}"
    return 1
  fi

  db_engine="$(cloud_db_engine "$cloud")"

  case "$COMPUTE_MODE" in
    vm)
      compute_type="vm"
      use_kubernetes="false"
      ;;
    kubernetes)
      compute_type="kubernetes"
      use_kubernetes="true"
      ;;
    both)
      compute_type="vm"
      use_kubernetes="true"
      ;;
  esac

  args+=("-var=compute_type=$compute_type" "-var=use_kubernetes=$use_kubernetes" "-var=db_engine=$db_engine")
  if [ "$COMPUTE_MODE" != "kubernetes" ]; then
    args+=("-var=vm_count=$vm_count")
  fi
  if [ "$COMPUTE_MODE" != "vm" ]; then
    args+=("-var=node_count=$NODE_COUNT")
  fi

  log "${CYAN}→ Processing $env/$cloud${RESET}"
  (
    cd "$dir"
    terraform init -backend=false -input=false
    case "$ACTION" in
      plan)
        terraform plan -input=false "${args[@]}"
        ;;
      apply)
        terraform apply -input=false -auto-approve "${args[@]}"
        ;;
      destroy)
        terraform destroy -input=false -auto-approve "${args[@]}"
        ;;
    esac
  ) 2>&1 | tee -a "$LOG_FILE" || {
    FAILED_COMBINATIONS+=("$env/$cloud")
    return 1
  }
}

main() {
  local compute_prompt=("VMs" "Kubernetes (EKS/GKE/AKS)" "Both")
  local db_prompt=("PostgreSQL" "MySQL" "SQL Server" "Aurora PostgreSQL (AWS only)" "Aurora MySQL (AWS only)")
  local compute_choice db_choice confirm

  check_dependencies
  banner
  prompt_multi_select SELECTED_ENVS "Select environments" "${ENVIRONMENTS[@]}"
  prompt_multi_select SELECTED_CLOUDS "Select clouds" "${CLOUDS[@]}"
  prompt_single_choice compute_choice "Select compute type" "${compute_prompt[@]}"
  case "$compute_choice" in
    "VMs") COMPUTE_MODE="vm" ;;
    "Kubernetes (EKS/GKE/AKS)") COMPUTE_MODE="kubernetes" ;;
    "Both") COMPUTE_MODE="both" ;;
  esac

  prompt_single_choice db_choice "Select database engine" "${db_prompt[@]}"
  case "$db_choice" in
    "PostgreSQL") DB_ENGINE_CHOICE="postgresql" ;;
    "MySQL") DB_ENGINE_CHOICE="mysql" ;;
    "SQL Server") DB_ENGINE_CHOICE="sqlserver" ;;
    "Aurora PostgreSQL (AWS only)") DB_ENGINE_CHOICE="aurora-postgresql" ;;
    "Aurora MySQL (AWS only)") DB_ENGINE_CHOICE="aurora-mysql" ;;
  esac
  validate_engine_clouds

  if [ "$COMPUTE_MODE" != "vm" ]; then
    prompt_node_count
  fi
  if [ "$COMPUTE_MODE" != "kubernetes" ]; then
    prompt_vm_counts
  fi
  prompt_action
  show_summary

  printf "%b" "${YELLOW}Proceed? [y/N] ${RESET}"
  read -r confirm
  case "$confirm" in
    y|Y|yes|YES|Yes) ;;
    *) die "Operation cancelled by user." ;;
  esac

  for env in "${SELECTED_ENVS[@]}"; do
    for cloud in "${SELECTED_CLOUDS[@]}"; do
      if ! run_terraform "$env" "$cloud"; then
        log "${RED}Failed: $env/$cloud${RESET}"
      else
        log "${GREEN}Completed: $env/$cloud${RESET}"
      fi
    done
  done

  if [ "${#FAILED_COMBINATIONS[@]}" -gt 0 ]; then
    log "${RED}${BOLD}Completed with failures:${RESET} $(join_by ', ' "${FAILED_COMBINATIONS[@]}")"
    exit 1
  fi

  log "${GREEN}${BOLD}All requested combinations completed successfully.${RESET}"
  log "Log file: $LOG_FILE"
}

main "$@"
