#!/usr/bin/env bash
# Terraform Multi-Cloud interactive deploy helper
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$PROJECT_ROOT/logs"
LOG_FILE="$PROJECT_ROOT/logs/deploy_$(date +%Y%m%d_%H%M%S).log"

# All interactive I/O goes directly to /dev/tty
tty_out() { printf "$@" >/dev/tty; }
tty_in()  { read -r "$@" </dev/tty; }

prompt_choice() {
  local -n _ret="$1"; local title="$2"; shift 2; local opts=("$@")
  while true; do
    tty_out "\n${YELLOW}%s${RESET}\n" "$title"
    local i=1; for o in "${opts[@]}"; do tty_out "  ${CYAN}%d)${RESET} %s\n" "$i" "$o"; ((i++)); done
    tty_out "${BOLD}> ${RESET}"; local sel; tty_in sel
    if [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#opts[@]} )); then
      _ret="${opts[sel-1]}"; return 0
    fi
    local slow; slow="$(printf '%s' "$sel" | tr '[:upper:]' '[:lower:]' | xargs)"
    for o in "${opts[@]}"; do
      [[ "$slow" == "$(printf '%s' "$o" | tr '[:upper:]' '[:lower:]')" ]] && { _ret="$o"; return 0; }
    done
    tty_out "${RED}Invalid: '%s' — enter a number 1-%d or the option name.${RESET}\n" "$sel" "${#opts[@]}"
  done
}

prompt_yesno() {
  local -n _yn="$1"; local msg="$2"; local def="${3:-y}"
  while true; do
    tty_out "${YELLOW}%s${RESET} " "$msg"; local r; tty_in r
    r="$(printf '%s' "${r:-$def}" | tr '[:upper:]' '[:lower:]' | xargs)"
    case "$r" in y|yes) _yn="true"; return 0;; n|no) _yn="false"; return 0;;
      *) tty_out "${RED}Please answer y or n.${RESET}\n";; esac
  done
}

prompt_number() {
  local -n _nr="$1"; local msg="$2"; local mn="$3" mx="$4" df="$5"
  while true; do
    tty_out "${YELLOW}%s${RESET} [%d-%d, default %d]: " "$msg" "$mn" "$mx" "$df"
    local v; tty_in v; v="${v:-$df}"
    [[ "$v" =~ ^[0-9]+$ ]] && (( v >= mn && v <= mx )) && { _nr="$v"; return 0; }
    tty_out "${RED}Enter a number between %d and %d.${RESET}\n" "$mn" "$mx"
  done
}

prompt_text() {
  local -n _txt="$1"; local msg="$2"
  while true; do
    tty_out "${YELLOW}%s${RESET} " "$msg"; local value; tty_in value
    value="$(printf '%s' "$value" | xargs)"
    if [[ -n "$value" ]]; then
      _txt="$value"; return 0
    fi
    tty_out "${RED}This value is required.${RESET}\n"
  done
}

parse_multiselect() {
  # parse_multiselect ARRAY_NAMEREF "input" item1 item2 ...
  local -n _ms="$1"; local input="$2"; shift 2; local valid=("$@")
  local -a sel=()
  IFS=',' read -r -a raw <<< "$input"
  for item in "${raw[@]}"; do
    item="$(printf '%s' "$item" | xargs | tr '[:upper:]' '[:lower:]')"
    local found=0
    for idx in "${!valid[@]}"; do
      local vlow; vlow="$(printf '%s' "${valid[$idx]}" | tr '[:upper:]' '[:lower:]')"
      local num=$(( idx + 1 ))
      if [[ "$item" == "$vlow" || "$item" == "$num" ]]; then
        sel+=("${valid[$idx]}"); found=1; break
      fi
    done
    if [[ "$item" == "all" ]]; then sel=("${valid[@]}"); break; fi
    (( found )) || { tty_out "${RED}Unknown: '%s'${RESET}\n" "$item"; return 1; }
  done
  (( ${#sel[@]} > 0 )) || { tty_out "${RED}Select at least one.${RESET}\n"; return 1; }
  # dedup
  local -A seen=()
  local deduped=()
  for v in "${sel[@]}"; do [[ -z "${seen[$v]:-}" ]] && { deduped+=("$v"); seen[$v]=1; }; done
  _ms=("${deduped[@]}")
}

# ── Banner ───────────────────────────────────────────────────────────────────
tty_out "\n${CYAN}${BOLD}╔══════════════════════════════════════════╗${RESET}\n"
tty_out "${CYAN}${BOLD}║   Terraform Multi-Cloud Deploy Helper    ║${RESET}\n"
tty_out "${CYAN}${BOLD}╚══════════════════════════════════════════╝${RESET}\n"
tty_out "  Log: %s\n" "$LOG_FILE"

# ── Environments ─────────────────────────────────────────────────────────────
SELECTED_ENVS=()
while true; do
  tty_out "\n${YELLOW}Select environment(s)${RESET} — comma-separated (e.g. 1,2 or dev,qa or all):\n"
  tty_out "  ${CYAN}1)${RESET} dev   ${CYAN}2)${RESET} qa   ${CYAN}3)${RESET} stage   ${CYAN}4)${RESET} prod\n"
  tty_out "${BOLD}> ${RESET}"; local_input=""; tty_in local_input
  parse_multiselect SELECTED_ENVS "$local_input" dev qa stage prod && break
done

# ── Clouds ───────────────────────────────────────────────────────────────────
SELECTED_CLOUDS=()
while true; do
  tty_out "\n${YELLOW}Select cloud(s)${RESET} — comma-separated (e.g. 1,3 or aws,gcp or all):\n"
  tty_out "  ${CYAN}1)${RESET} aws   ${CYAN}2)${RESET} azure   ${CYAN}3)${RESET} gcp\n"
  tty_out "${BOLD}> ${RESET}"; local_input=""; tty_in local_input
  parse_multiselect SELECTED_CLOUDS "$local_input" aws azure gcp && break
done

# ── Action ───────────────────────────────────────────────────────────────────
ACTION_ARG="${1:-}"; ACTION=""
if [[ -n "$ACTION_ARG" ]]; then
  ACTION="$(printf '%s' "$ACTION_ARG" | tr '[:upper:]' '[:lower:]')"
  [[ "$ACTION" =~ ^(plan|apply|destroy)$ ]] || { tty_out "${RED}Invalid action: %s${RESET}\n" "$ACTION"; exit 1; }
  tty_out "${YELLOW}Action (from argument): %s${RESET}\n" "$ACTION"
else
  prompt_choice ACTION "Select action:" plan apply destroy
fi

# ── Compute ──────────────────────────────────────────────────────────────────
COMPUTE_TYPE=""
prompt_choice COMPUTE_TYPE "Select compute type:" vm kubernetes

NODE_COUNT=2
prompt_number NODE_COUNT "VM / node count" 1 50 2

# ── Database ──────────────────────────────────────────────────────────────────
ENABLE_DATABASE=""; prompt_yesno ENABLE_DATABASE "Deploy database?  [Y/n]:" y

DB_ENGINE="postgresql"
if [[ "$ENABLE_DATABASE" == "true" ]]; then
  prompt_choice DB_ENGINE "Select database engine:" postgresql mysql sqlserver aurora-postgresql aurora-mysql
fi

# ── Redis ─────────────────────────────────────────────────────────────────────
ENABLE_REDIS=""; prompt_yesno ENABLE_REDIS "Deploy Redis?     [y/N]:" n

# ── Cloud-specific credentials ──────────────────────────────────────────────────
GCP_PROJECT_ID=""
if printf '%s\n' "${SELECTED_CLOUDS[@]}" | grep -q "^gcp$"; then
  prompt_text GCP_PROJECT_ID "GCP Project ID (required for GCP environments)"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
tty_out "\n${CYAN}${BOLD}┌────────────────────────────────────────────┐${RESET}\n"
tty_out "${CYAN}${BOLD}│              Execution Summary             │${RESET}\n"
tty_out "${CYAN}${BOLD}└────────────────────────────────────────────┘${RESET}\n"
tty_out "  %-14s : ${GREEN}%s${RESET}\n" "Environments" "${SELECTED_ENVS[*]}"
tty_out "  %-14s : ${GREEN}%s${RESET}\n" "Clouds"       "${SELECTED_CLOUDS[*]}"
tty_out "  %-14s : ${GREEN}%s${RESET}\n" "Action"       "$ACTION"
tty_out "  %-14s : ${GREEN}%s${RESET}\n" "Compute"      "$COMPUTE_TYPE"
tty_out "  %-14s : ${GREEN}%s${RESET}\n" "Count"        "$NODE_COUNT"
tty_out "  %-14s : ${GREEN}%s${RESET}\n" "Database"     "$ENABLE_DATABASE"
tty_out "  %-14s : ${GREEN}%s${RESET}\n" "DB Engine"    "$DB_ENGINE"
tty_out "  %-14s : ${GREEN}%s${RESET}\n" "Redis"        "$ENABLE_REDIS"
[[ -n "$GCP_PROJECT_ID" ]] && tty_out "  %-14s : ${GREEN}%s${RESET}\n" "GCP Project" "$GCP_PROJECT_ID"
tty_out "\n  Combinations:\n"
for e in "${SELECTED_ENVS[@]}"; do
  for c in "${SELECTED_CLOUDS[@]}"; do
    tty_out "    ${CYAN}•${RESET} environments/%s/%s\n" "$e" "$c"
  done
done

CONFIRM=""; prompt_yesno CONFIRM "Proceed? [Y/n]:" y
[[ "$CONFIRM" == "true" ]] || { tty_out "${YELLOW}Cancelled.${RESET}\n"; exit 0; }

# ── Post-apply resource summary ─────────────────────────────────────────────
show_deployment_summary() {
  local label="$1"
  local env_dir="$2"
  local tf_out
  tf_out=$(cd "$env_dir" && terraform output -json 2>/dev/null) || return 0
  [[ -z "$tf_out" || "$tf_out" == "{}" ]] && return 0

  tty_out "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
  tty_out "${CYAN}${BOLD}  📋  Deployed Resources — %s${RESET}\n" "$label"
  tty_out "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

  local _py; _py=$(mktemp /tmp/tf_summary_XXXXXX.py)
  cat > "$_py" << 'PYEOF'
import sys, json

data = json.loads(sys.stdin.read())

SECTIONS = [
  ("🖥  Compute / VMs", [
    "instance_names","instance_group_name","instance_group_manager_name",
    "instance_ids","vm_ids","vm_names",
    "vm_ips","private_ips","vm_private_ips","instance_private_ips",
    "instance_zones","gcloud_list_instances_cmd",
  ]),
  ("☸  Kubernetes", [
    "gke_cluster_name","gke_endpoint","gke_kubeconfig_command",
    "eks_cluster_name","eks_cluster_endpoint","eks_kubeconfig_command",
    "aks_cluster_name","aks_host","aks_kubeconfig_command",
  ]),
  ("🔐 Access / Bastion", [
    "bastion_public_ip","bastion_iap_ssh_command","bastion_ssh_command",
  ]),
  ("🌐 Network", [
    "vpc_id","vnet_id","network_id",
    "public_subnet_ids","private_subnet_ids","db_subnet_ids",
    "public_subnet_id","private_subnet_id","db_subnet_id",
    "private_subnet_self_link",
  ]),
  ("🗄  Database", [
    "db_endpoint","db_reader_endpoint","db_private_ip","db_public_ip",
    "db_connection_name","db_fqdn","db_port","db_engine",
  ]),
  ("⚡ Redis", [
    "redis_host","redis_hostname","redis_endpoint","redis_port",
  ]),
  ("🪣 Storage", [
    "bucket_names","bucket_name","bucket_url","bucket_id","bucket_arn",
    "storage_account_name","container_name",
  ]),
  ("🔑 IAM", [
    "compute_sa_email","gke_sa_email",
  ]),
]

printed = set()

def fmt(v):
  if isinstance(v, list):
    v = [x for x in v if x is not None and x != ""]
    if not v:
      return None
    return ("\n" + "\n".join(f"      • {i}" for i in v)) if len(v) > 1 else str(v[0])
  return None if v is None or v == "" else str(v)

for title, keys in SECTIONS:
  rows = [(k, fmt(data[k]["value"])) for k in keys if k in data and fmt(data[k]["value"])]
  if rows:
    print(f"\n  {title}")
    for k, fv in rows:
      print(f"    {k}: {fv}")
    printed.update(k for k, _ in rows)

rest = [(k, fmt(data[k]["value"])) for k in data if k not in printed and fmt(data[k]["value"])]
if rest:
  print("\n  📌 Other")
  for k, fv in rest:
    print(f"    {k}: {fv}")
PYEOF

  local formatted
  formatted=$(printf '%s' "$tf_out" | python3 "$_py" 2>/dev/null) || formatted=""
  rm -f "$_py"

  if [[ -n "$formatted" ]]; then
    while IFS= read -r line; do tty_out "%s\n" "$line"; done <<< "$formatted"
  fi
  tty_out "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n\n"
}

# ── Execute ──────────────────────────────────────────────────────────────────
exec > >(tee -a "$LOG_FILE") 2>&1

FAILED_COMBOS=()

for env in "${SELECTED_ENVS[@]}"; do
  for cloud in "${SELECTED_CLOUDS[@]}"; do
    ENV_DIR="$PROJECT_ROOT/environments/$env/$cloud"
    if [[ ! -d "$ENV_DIR" ]]; then
      tty_out "${YELLOW}⚠️   Skipping %s/%s — directory not found${RESET}\n" "$env" "$cloud"
      continue
    fi

    tty_out "\n${CYAN}${BOLD}══> [%s/%s] %s${RESET}\n" "$env" "$cloud" "$ACTION"
    pushd "$ENV_DIR" >/dev/null

    TF_VARS=(
      "-var=environment=$env"
      "-var=project=terraform-$env"
      "-var=compute_type=$COMPUTE_TYPE"
      "-var=vm_count=$NODE_COUNT"
      "-var=node_count=$NODE_COUNT"
      "-var=enable_database=$ENABLE_DATABASE"
      "-var=db_engine=$DB_ENGINE"
      "-var=enable_redis=$ENABLE_REDIS"
    )

    if [[ "$cloud" == "gcp" && -n "$GCP_PROJECT_ID" ]]; then
      TF_VARS+=("-var=project_id=$GCP_PROJECT_ID")
    fi

    terraform init -input=false -no-color
    rc=0
    _did_apply=false
    case "$ACTION" in
      plan)
        terraform plan -input=false -no-color "${TF_VARS[@]}" -out=tfplan || rc=$?
        if (( rc == 0 )); then
          _apply_now=""
          prompt_yesno _apply_now "  ✅ Plan succeeded — apply now?" n
          if [[ "$_apply_now" == "true" ]]; then
            terraform apply -input=false -no-color -auto-approve tfplan || rc=$?
            _did_apply=true
          fi
        fi
        ;;
      apply)
        terraform plan  -input=false -no-color "${TF_VARS[@]}" -out=tfplan || rc=$?
        if (( rc == 0 )); then
          terraform apply -input=false -no-color -auto-approve tfplan || rc=$?
          _did_apply=true
        fi
        ;;
      destroy)
        terraform destroy -input=false -no-color -auto-approve "${TF_VARS[@]}" || rc=$?
        ;;
    esac

    popd >/dev/null
    if (( rc == 0 )); then
      tty_out "${GREEN}✅  %s/%s — %s complete${RESET}\n" "$env" "$cloud" "$ACTION"
      [[ "$_did_apply" == "true" ]] && show_deployment_summary "$env/$cloud" "$ENV_DIR"
    else
      tty_out "${RED}❌  %s/%s — %s FAILED (exit %d)${RESET}\n" "$env" "$cloud" "$ACTION" "$rc"
      FAILED_COMBOS+=("$env/$cloud")
    fi
  done
done

if (( ${#FAILED_COMBOS[@]} > 0 )); then
  tty_out "\n${RED}${BOLD}Failed: %s${RESET}\n" "${FAILED_COMBOS[*]}"
  tty_out "See log: %s\n" "$LOG_FILE"
  exit 1
fi

tty_out "\n${GREEN}${BOLD}All actions completed successfully!${RESET}\n"
tty_out "Log saved: %s\n\n" "$LOG_FILE"
