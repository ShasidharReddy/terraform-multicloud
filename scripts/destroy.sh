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
LOG_FILE="$LOG_DIR/destroy_$(date +%Y%m%d_%H%M%S).log"

ENVIRONMENTS=(dev qa stage prod)
CLOUDS=(aws azure gcp)
SELECTED_ENVS=()
SELECTED_CLOUDS=()
PARSED_SELECTION=()
FAILED_COMBINATIONS=()

log() {
  printf "%b\n" "$1" | tee -a "$LOG_FILE"
}

die() {
  log "${RED}${BOLD}Error:${RESET} $1"
  exit 1
}

on_error() {
  local exit_code=$?
  log "${RED}${BOLD}Destroy workflow aborted.${RESET} Review log: $LOG_FILE"
  exit "$exit_code"
}
trap on_error ERR

banner() {
  log "${CYAN}${BOLD}"
  log "╔══════════════════════════════════════════════╗"
  log "║        Terraform Multi-Cloud Destroy        ║"
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
  return 0
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

prompt_vm_counts() {
  local env input default_count

  for env in "${SELECTED_ENVS[@]}"; do
    default_count="$(default_vm_count "$env")"
    set_vm_count "$env" "$default_count"
  done

  printf "%b" "${YELLOW}Override VM count per selected environment for destroy? [y/N]:${RESET} "
  read -r input
  case "$input" in
    y|Y|yes|YES|Yes) ;;
    *) return ;;
  esac

  for env in "${SELECTED_ENVS[@]}"; do
    default_count="$(default_vm_count "$env")"
    while true; do
      printf "%b" "${YELLOW}VM count for $env (1-10, Enter for default $default_count):${RESET} "
      read -r input
      if [ -z "$input" ]; then
        set_vm_count "$env" "$default_count"
        break
      fi
      if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le 10 ]; then
        set_vm_count "$env" "$input"
        break
      fi
      log "${RED}VM count must be a number from 1 to 10.${RESET}"
    done
  done
}

run_destroy() {
  local env="$1"
  local cloud="$2"
  local dir="$PROJECT_ROOT/environments/$env/$cloud"
  local vm_count="$(get_vm_count "$env")"

  if [ ! -d "$dir" ]; then
    FAILED_COMBINATIONS+=("$env/$cloud")
    log "${RED}Missing directory: $dir${RESET}"
    return 1
  fi

  log "${CYAN}→ Destroying $env/$cloud${RESET}"
  (
    cd "$dir"
    terraform init -backend=false -input=false
    terraform destroy -input=false -var="vm_count=$vm_count" -auto-approve
  ) 2>&1 | tee -a "$LOG_FILE" || {
    FAILED_COMBINATIONS+=("$env/$cloud")
    return 1
  }
}

main() {
  local env cloud confirmation

  check_dependencies
  banner
  prompt_multi_select SELECTED_ENVS "Select environments to destroy" "${ENVIRONMENTS[@]}"
  prompt_multi_select SELECTED_CLOUDS "Select clouds to destroy" "${CLOUDS[@]}"
  prompt_vm_counts

  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "  Destroy Plan"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "  Environments : $(join_by ', ' "${SELECTED_ENVS[@]}")"
  log "  Clouds       : $(join_by ', ' "${SELECTED_CLOUDS[@]}")"
  log "  Action       : destroy"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  printf "%b" "${RED}${BOLD}Type 'destroy' to confirm:${RESET} "
  read -r confirmation
  [ "$confirmation" = "destroy" ] || die "Destroy confirmation failed."

  for env in "${SELECTED_ENVS[@]}"; do
    for cloud in "${SELECTED_CLOUDS[@]}"; do
      if ! run_destroy "$env" "$cloud"; then
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

  log "${GREEN}${BOLD}Destroy completed successfully.${RESET}"
  log "Log file: $LOG_FILE"
}

main "$@"
