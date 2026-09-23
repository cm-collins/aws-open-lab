#!/usr/bin/env bash
# Delete a monthly cost budget. Interactive numbered list on a TTY, or --name / BUDGET_NAME.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=lib/budget-select.sh
source "${SCRIPT_DIR}/lib/budget-select.sh"

BUDGET_LIST_JSON=""
BUDGET_NAMES=()
BUDGET_SELECTED_NAME=""

print_delete_usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [options]

  (no args)     On a TTY: list all budgets and pick by number (1, 2, …).
                Off a TTY: uses BUDGET_NAME from config/.env.

  --name NAME   Delete this budget (non-interactive).
  --interactive Force numbered list even if BUDGET_NAME is set.
  -h, --help    Show this help.

Examples:
  bash delete-monthly-cost-budget.sh
  bash delete-monthly-cost-budget.sh --name lab-monthly-spend-cli
EOF
}

lab_log_info "Starting delete-monthly-cost-budget.sh"
lab_require_commands aws jq

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  print_delete_usage
  exit 0
fi

init_aws_cli
if ! ensure_aws_session; then
  po_budget_run_context "AWS Open Lab — Delete Monthly Cost Budget" "Lab 1 · budgets"
  lab_preflight_failed "Fix AWS credentials and re-run."
fi

po_budget_run_context "AWS Open Lab — Delete Monthly Cost Budget" "Lab 1 · budgets"

lab_set_phase "Resolve AWS account"
ACCOUNT_ID="$(aws_account_id)"

resolve_rc=0
budget_resolve_delete_target "$ACCOUNT_ID" "$@" || resolve_rc=$?

if [[ "$resolve_rc" == 10 ]]; then
  print_delete_usage
  exit 0
fi
if [[ "$resolve_rc" == 3 ]]; then
  po_section "Execution"
  po_table_header
  po_row "User selection" "SKIP" "cancelled"
  po_outcome "NO-OP" "No budget deleted."
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

po_section "Configuration"
po_table_header
po_row "Config file" "OK" "${LAB_CONFIG_FILE}"
po_row "AWS account" "OK" "$(po_mask_account "$ACCOUNT_ID")"
if [[ -z "$BUDGET_NAME" ]]; then
  po_row "Budget name" "SKIP" "none in account"
  po_outcome "NO-OP" "No budgets exist in this account."
  exit 0
fi
po_row "Selected budget" "OK" "${BUDGET_NAME}"

po_section "Execution"
po_table_header

if ! budget_exists "$ACCOUNT_ID" "$BUDGET_NAME"; then
  po_row "Budget exists" "SKIP" "not found"
  po_row "DeleteBudget API" "SKIP" "not called (idempotent)"
  po_outcome "NO-OP" "Nothing to delete."
  exit 0
fi

LIMIT="$(budget_limit_usd "$ACCOUNT_ID" "$BUDGET_NAME")"
po_row "Budget exists" "OK" "USD ${LIMIT} monthly limit"

if lab_run "AWS Budgets DeleteBudget" aws "${AWS_PROFILE_ARGS[@]}" budgets delete-budget \
  --account-id "$ACCOUNT_ID" \
  --budget-name "$BUDGET_NAME"; then
  po_row "DeleteBudget API" "OK" "submitted"
else
  po_row "DeleteBudget API" "FAIL" "$(lab_aws_first_line)"
  po_outcome "FAILED" "See ERROR lines on stderr."
  exit 1
fi

po_outcome "DELETED" "Budget '${BUDGET_NAME}' removed from account $(po_mask_account "$ACCOUNT_ID")."
