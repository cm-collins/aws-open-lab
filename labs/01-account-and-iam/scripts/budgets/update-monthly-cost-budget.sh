#!/usr/bin/env bash
# Update monthly USD limit. TTY: pick budget + type new limit. Else: --limit or .env.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=lib/budget-select.sh
source "${SCRIPT_DIR}/lib/budget-select.sh"

BUDGET_LIST_JSON=""
BUDGET_NAMES=()
BUDGET_SELECTED_NAME=""
UPDATE_FLAG_LIMIT=""
UPDATE_ARGS=()

print_update_usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [options]

  (no args)     On a TTY: pick a budget by number, then type the new monthly limit (USD).
                Off a TTY: uses BUDGET_NAME and BUDGET_LIMIT_USD from config/.env.

  --name NAME   Budget to update (skips budget menu when not using -i).
  --limit USD   New monthly limit (skips typing; use with --name in scripts/CI).
  --interactive Force budget numbered list.
  -h, --help    Show this help.

Note: This script only changes the monthly USD limit. Email alerts stay as-is (recreate budget to change email).

Examples:
  bash update-monthly-cost-budget.sh
  bash update-monthly-cost-budget.sh --name lab-monthly-spend-cli --limit 20
EOF
}

parse_update_args() {
  UPDATE_ARGS=()
  UPDATE_FLAG_LIMIT=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --limit)
        UPDATE_FLAG_LIMIT="${2:?--limit requires a USD amount}"
        shift 2
        ;;
      --name)
        UPDATE_ARGS+=("$1" "${2:?--name requires a value}")
        shift 2
        ;;
      --interactive | -i | -h | --help)
        UPDATE_ARGS+=("$1")
        shift
        ;;
      *)
        lab_log_error "Unknown argument: $1"
        return 2
        ;;
    esac
  done
  return 0
}

lab_log_info "Starting update-monthly-cost-budget.sh"
lab_require_commands aws jq awk

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  print_update_usage
  exit 0
fi

parse_update_args "$@" || exit 2

init_aws_cli
if ! ensure_aws_session; then
  po_budget_run_context "AWS Open Lab — Update Monthly Cost Budget" "Lab 1 · budgets"
  lab_preflight_failed "Fix AWS credentials and re-run."
fi

po_budget_run_context "AWS Open Lab — Update Monthly Cost Budget" "Lab 1 · budgets"

lab_set_phase "Resolve AWS account"
ACCOUNT_ID="$(aws_account_id)"

resolve_rc=0
budget_resolve_update_target "$ACCOUNT_ID" "${UPDATE_ARGS[@]}" || resolve_rc=$?

if [[ "$resolve_rc" == 10 ]]; then
  print_update_usage
  exit 0
fi
if [[ "$resolve_rc" == 3 ]]; then
  po_section "Execution"
  po_table_header
  po_row "User selection" "SKIP" "cancelled"
  po_outcome "NO-OP" "No budget updated."
  exit 0
fi
if [[ "$resolve_rc" != 0 ]]; then
  po_section "Execution"
  po_table_header
  po_row "Budget list" "FAIL" "$(lab_aws_first_line)"
  po_outcome "FAILED" "Could not list or select a budget."
  exit 1
fi

BUDGET_NAME="${BUDGET_SELECTED_NAME:-}"

if [[ -z "$BUDGET_NAME" ]]; then
  po_section "Configuration"
  po_table_header
  po_row "Budget name" "FAIL" "none in account"
  po_outcome "FAILED" "Create a budget first."
  exit 1
fi

if ! budget_exists "$ACCOUNT_ID" "$BUDGET_NAME"; then
  po_section "Execution"
  po_table_header
  po_row "Budget exists" "FAIL" "not found"
  po_outcome "FAILED" "Run create-monthly-cost-budget.sh first."
  exit 1
fi

PREVIOUS="$(budget_limit_usd "$ACCOUNT_ID" "$BUDGET_NAME")"

limit_rc=0
if [[ -n "$UPDATE_FLAG_LIMIT" ]]; then
  if ! budget_validate_usd_amount "$UPDATE_FLAG_LIMIT"; then
    lab_log_error "Invalid --limit: ${UPDATE_FLAG_LIMIT}"
    po_outcome "FAILED" "Use a positive USD amount, e.g. --limit 20"
    exit 1
  fi
  BUDGET_LIMIT_USD="$UPDATE_FLAG_LIMIT"
  lab_log_info "Using --limit USD ${BUDGET_LIMIT_USD}"
elif [[ -t 0 ]] && [[ -t 1 ]] && [[ -e /dev/tty ]]; then
  budget_prompt_monthly_limit "$PREVIOUS" "${BUDGET_LIMIT_USD:-}" || limit_rc=$?
  if [[ "$limit_rc" == 3 ]]; then
    po_section "Execution"
    po_table_header
    po_row "New limit" "SKIP" "cancelled"
    po_outcome "NO-OP" "No budget updated."
    exit 0
  fi
  if [[ "$limit_rc" != 0 ]]; then
    po_outcome "FAILED" "Could not read a valid monthly limit."
    exit 1
  fi
elif [[ -n "${BUDGET_LIMIT_USD:-}" ]]; then
  if ! budget_validate_usd_amount "$BUDGET_LIMIT_USD"; then
    po_outcome "FAILED" "Invalid BUDGET_LIMIT_USD in .env"
    exit 1
  fi
  lab_log_info "Using BUDGET_LIMIT_USD from .env"
else
  lab_log_error "Non-interactive: pass --limit or set BUDGET_LIMIT_USD in .env"
  po_outcome "FAILED" "Pass --limit USD or run from a terminal to type the amount."
  exit 1
fi

if budget_amount_equal "$PREVIOUS" "$BUDGET_LIMIT_USD"; then
  po_section "Configuration"
  po_table_header
  po_row "Selected budget" "OK" "${BUDGET_NAME}"
  po_row "Target limit" "SKIP" "USD ${BUDGET_LIMIT_USD} (same as AWS)"
  po_outcome "NO-OP" "Limit unchanged."
  exit 0
fi

po_section "Configuration"
po_table_header
po_row "Config file" "OK" "${LAB_CONFIG_FILE}"
po_row "AWS account" "OK" "$(po_mask_account "$ACCOUNT_ID")"
po_row "Selected budget" "OK" "${BUDGET_NAME}"
po_row "Target limit" "OK" "USD ${BUDGET_LIMIT_USD}"

po_section "Execution"
po_table_header
po_row "Budget exists" "OK" "found"
po_row "Previous limit" "OK" "USD ${PREVIOUS}"

TMP_BUDGET="$(mktemp)"
trap 'rm -f "$TMP_BUDGET"' EXIT

lab_set_phase "Build updated budget document"
if ! lab_run "Build budget document (jq)" jq -n \
  --arg name "$BUDGET_NAME" \
  --arg amount "$BUDGET_LIMIT_USD" \
  '{
    BudgetName: $name,
    BudgetLimit: { Amount: $amount, Unit: "USD" },
    TimeUnit: "MONTHLY",
    BudgetType: "COST"
  }' >"$TMP_BUDGET"; then
  po_row "Budget payload" "FAIL" "$(lab_aws_first_line)"
  po_outcome "FAILED" "Could not build budget JSON."
  exit 1
fi

if lab_run "AWS Budgets UpdateBudget" aws "${AWS_PROFILE_ARGS[@]}" budgets update-budget \
  --account-id "$ACCOUNT_ID" \
  --new-budget "file://${TMP_BUDGET}"; then
  po_row "UpdateBudget API" "OK" "submitted"
else
  po_row "UpdateBudget API" "FAIL" "$(lab_aws_first_line)"
  po_outcome "FAILED" "See ERROR lines on stderr."
  exit 1
fi

budget_offer_sync_limit_to_env "$BUDGET_LIMIT_USD" "$BUDGET_NAME"

po_outcome "UPDATED" "Limit changed USD ${PREVIOUS} → USD ${BUDGET_LIMIT_USD}."
