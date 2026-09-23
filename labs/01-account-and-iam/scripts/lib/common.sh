#!/usr/bin/env bash
# Shared helpers for Lab 1 AWS CLI scripts.

set -euo pipefail

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../shared/scripts/lib/premium-output.sh
source "${_LIB_DIR}/../../../shared/scripts/lib/premium-output.sh"
# shellcheck source=../../../shared/scripts/lib/lab-runtime.sh
source "${_LIB_DIR}/../../../shared/scripts/lib/lab-runtime.sh"

_LAB_CONFIG_DIR="$(cd "${_LIB_DIR}/../../config" && pwd)"
lab_runtime_init \
  "${_LAB_CONFIG_DIR}/.env" \
  "${_LAB_CONFIG_DIR}/budgets.env.example" \
  "required"

require_env() {
  lab_require_env "$@"
}

log() {
  lab_log_info "$*"
}

AWS_PROFILE_ARGS=()

init_aws_cli() {
  lab_set_phase "Initialize AWS CLI profile"
  AWS_PROFILE_ARGS=()
  if [[ -n "${AWS_PROFILE:-}" ]]; then
    AWS_PROFILE_ARGS=(--profile "$AWS_PROFILE")
    lab_log_info "Using AWS profile: ${AWS_PROFILE}"
  else
    lab_log_warn "AWS_PROFILE unset; using default credential chain"
  fi
}

ensure_aws_session() {
  lab_set_phase "Verify AWS credentials (STS)"
  local account arn json
  if ! json="$(aws "${AWS_PROFILE_ARGS[@]}" sts get-caller-identity --output json 2>&1)"; then
    LAB_AWS_LAST_ERROR="$json"
    lab_log_error "Cannot call STS: $(lab_aws_first_line)"
    return 1
  fi
  account="$(printf '%s' "$json" | jq -r '.Account')"
  arn="$(printf '%s' "$json" | jq -r '.Arn')"
  lab_log_info "Caller: ${arn##*:user/} account $(po_mask_account "$account")"
  return 0
}

aws_account_id() {
  aws "${AWS_PROFILE_ARGS[@]}" sts get-caller-identity --query Account --output text
}

aws_caller_arn() {
  aws "${AWS_PROFILE_ARGS[@]}" sts get-caller-identity --query Arn --output text
}

budget_exists() {
  local account_id="$1"
  local budget_name="$2"
  local found
  lab_log_info "Checking if budget exists: ${budget_name}"
  found="$(aws "${AWS_PROFILE_ARGS[@]}" budgets describe-budgets \
    --account-id "$account_id" \
    --query "Budgets[?BudgetName=='${budget_name}'].BudgetName | [0]" \
    --output text 2>/dev/null || true)"
  [[ -n "$found" && "$found" != "None" ]]
}

budget_limit_usd() {
  local account_id="$1"
  local budget_name="$2"
  aws "${AWS_PROFILE_ARGS[@]}" budgets describe-budget \
    --account-id "$account_id" \
    --budget-name "$budget_name" \
    --query 'Budget.BudgetLimit.Amount' \
    --output text 2>/dev/null || echo "—"
}

# Prints describe-budget JSON on stdout; non-zero on API error.
budget_describe_json() {
  local account_id="$1"
  local budget_name="$2"
  aws "${AWS_PROFILE_ARGS[@]}" budgets describe-budget \
    --account-id "$account_id" \
    --budget-name "$budget_name" \
    --output json
}

# Prints describe-notifications-for-budget JSON on stdout.
budget_notifications_json() {
  local account_id="$1"
  local budget_name="$2"
  aws "${AWS_PROFILE_ARGS[@]}" budgets describe-notifications-for-budget \
    --account-id "$account_id" \
    --budget-name "$budget_name" \
    --output json
}

# Normalize budget amounts for comparison (10 vs 10.0).
budget_amount_equal() {
  local a="$1"
  local b="$2"
  awk -v a="$a" -v b="$b" 'BEGIN {
    if (a == b) exit 0
    if (a + 0 == b + 0) exit 0
    exit 1
  }'
}

# Sets VERIFY_EXPECT_* and VERIFY_*_ENV_KEY for console|cli verify modes.
budget_resolve_verify_expectations() {
  local mode="$1"
  case "$mode" in
    console)
      VERIFY_EXPECT_NAME="${BUDGET_NAME_CONSOLE:-${BUDGET_NAME:-}}"
      VERIFY_EXPECT_LIMIT="${BUDGET_LIMIT_USD_CONSOLE:-${BUDGET_LIMIT_USD:-}}"
      VERIFY_NAME_ENV_KEY="BUDGET_NAME_CONSOLE"
      VERIFY_LIMIT_ENV_KEY="BUDGET_LIMIT_USD_CONSOLE"
      ;;
    cli)
      VERIFY_EXPECT_NAME="${BUDGET_NAME_CLI:-${BUDGET_NAME:-}}"
      VERIFY_EXPECT_LIMIT="${BUDGET_LIMIT_USD_CLI:-${BUDGET_LIMIT_USD:-}}"
      VERIFY_NAME_ENV_KEY="BUDGET_NAME_CLI"
      VERIFY_LIMIT_ENV_KEY="BUDGET_LIMIT_USD_CLI"
      ;;
    *)
      lab_log_error "Unknown verify mode: ${mode}"
      return 1
      ;;
  esac
  export VERIFY_EXPECT_NAME VERIFY_EXPECT_LIMIT VERIFY_NAME_ENV_KEY VERIFY_LIMIT_ENV_KEY
}

# Pending SNS email subscriptions for this address (budget alerts use SNS).
budget_sns_email_pending_count() {
  local email="$1"
  local json
  if ! json="$(aws "${AWS_PROFILE_ARGS[@]}" sns list-subscriptions --output json 2>&1)"; then
    LAB_AWS_LAST_ERROR="$json"
    printf '0'
    return 1
  fi
  jq -r --arg e "${email,,}" '
    [.Subscriptions[]
      | select(.Protocol == "email")
      | select((.Endpoint | ascii_downcase) == $e)
      | select(.SubscriptionArn | test("PendingConfirmation"))
    ] | length
  ' <<<"$json"
}

po_budget_run_context() {
  local script_title="$1"
  local lab="$2"
  po_banner "$script_title" "${lab} · $(po_timestamp_utc) · profile ${AWS_PROFILE:-default}"
}

lab_preflight_failed() {
  local detail="$1"
  po_section "Preflight"
  po_table_header
  po_row "AWS session" "FAIL" "$(lab_aws_first_line)"
  po_outcome "FAILED" "$detail"
  exit 1
}
