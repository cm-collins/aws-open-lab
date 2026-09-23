#!/usr/bin/env bash
# Create a monthly COST budget (Lab 1 guardrail). Notifications: 85% / 100% actual, 100% forecast.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

lab_log_info "Starting create-monthly-cost-budget.sh"
lab_require_commands aws jq
require_env BUDGET_NAME BUDGET_LIMIT_USD BUDGET_EMAIL

init_aws_cli
if ! ensure_aws_session; then
  po_budget_run_context "AWS Open Lab — Create Monthly Cost Budget" "Lab 1 · budgets"
  lab_preflight_failed "Fix AWS credentials (Lab 2 CLI runbook) and re-run."
fi

po_budget_run_context "AWS Open Lab — Create Monthly Cost Budget" "Lab 1 · budgets"

lab_set_phase "Resolve AWS identity"
ACCOUNT_ID="$(aws_account_id)"
ARN="$(aws_caller_arn)"

po_section "Configuration"
po_table_header
po_row "Config file" "OK" "${LAB_CONFIG_FILE}"
po_row "AWS account" "OK" "$(po_mask_account "$ACCOUNT_ID")"
po_row "Caller" "OK" "${ARN##*:user/}"
po_row "Budget name" "OK" "${BUDGET_NAME}"
po_row "Monthly limit" "OK" "USD ${BUDGET_LIMIT_USD}"
po_row "Notify email" "OK" "$(po_mask_email "${BUDGET_EMAIL}")"

po_section "Execution"
po_table_header

if budget_exists "$ACCOUNT_ID" "$BUDGET_NAME"; then
  po_row "Budget availability" "SKIP" "already exists"
  po_row "CreateBudget API" "SKIP" "not called (idempotent)"
  po_outcome "SKIPPED" "No change. Use update-monthly-cost-budget.sh to change limit."
  exit 0
fi

po_row "Budget availability" "OK" "name free"

lab_set_phase "Build budget JSON payloads"
TMP_BUDGET="$(mktemp)"
TMP_NOTIF="$(mktemp)"
trap 'rm -f "$TMP_BUDGET" "$TMP_NOTIF"' EXIT

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
  po_outcome "FAILED" "Fix jq or budget variables in .env"
  exit 1
fi

if ! lab_run "Build notification subscribers (jq)" jq -n \
  --arg email "$BUDGET_EMAIL" \
  '[
    {
      Notification: {
        NotificationType: "ACTUAL",
        ComparisonOperator: "GREATER_THAN",
        Threshold: 85,
        ThresholdType: "PERCENTAGE"
      },
      Subscribers: [{ SubscriptionType: "EMAIL", Address: $email }]
    },
    {
      Notification: {
        NotificationType: "ACTUAL",
        ComparisonOperator: "GREATER_THAN",
        Threshold: 100,
        ThresholdType: "PERCENTAGE"
      },
      Subscribers: [{ SubscriptionType: "EMAIL", Address: $email }]
    },
    {
      Notification: {
        NotificationType: "FORECASTED",
        ComparisonOperator: "GREATER_THAN",
        Threshold: 100,
        ThresholdType: "PERCENTAGE"
      },
      Subscribers: [{ SubscriptionType: "EMAIL", Address: $email }]
    }
  ]' >"$TMP_NOTIF"; then
  po_row "Notification payload" "FAIL" "$(lab_aws_first_line)"
  po_outcome "FAILED" "Fix BUDGET_EMAIL in .env"
  exit 1
fi

po_row "Budget payload" "OK" "generated"
po_row "Notification payload" "OK" "3 alerts"

if lab_run "AWS Budgets CreateBudget" aws "${AWS_PROFILE_ARGS[@]}" budgets create-budget \
  --account-id "$ACCOUNT_ID" \
  --budget "file://${TMP_BUDGET}" \
  --notifications-with-subscribers "file://${TMP_NOTIF}"; then
  po_row "CreateBudget API" "OK" "submitted"
else
  po_row "CreateBudget API" "FAIL" "$(lab_aws_first_line)"
  po_outcome "FAILED" "See ERROR lines on stderr (IAM budgets permissions, limits, or email)."
  exit 1
fi

po_row "Alert thresholds" "OK" "85% / 100% actual, 100% forecast"

po_section "Notifications"
po_table_header
po_row "Email subscriber" "OK" "$(po_mask_email "${BUDGET_EMAIL}")"
po_row "SNS confirm required" "WARN" "check inbox if new address"

po_outcome "CREATED" "Confirm AWS budget email subscription if prompted."
