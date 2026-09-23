#!/usr/bin/env bash
# Shared verify logic. Set BUDGET_VERIFY_MODE=console|cli before sourcing.

: "${BUDGET_VERIFY_MODE:?BUDGET_VERIFY_MODE must be console or cli}"

case "$BUDGET_VERIFY_MODE" in
  console)
    VERIFY_MODE_LABEL="Console template (runbook: billing-alert)"
    VERIFY_BANNER="AWS Open Lab — Verify Monthly Cost Budget (console)"
    VERIFY_ON_MISSING="Set BUDGET_NAME_CONSOLE (or BUDGET_NAME) to your console budget, e.g. lab-monthly-spend."
    ;;
  cli)
    VERIFY_MODE_LABEL="CLI create script (runbook 6)"
    VERIFY_BANNER="AWS Open Lab — Verify Monthly Cost Budget (CLI)"
    VERIFY_ON_MISSING="Set BUDGET_NAME_CLI (or BUDGET_NAME) to your CLI budget or run create-monthly-cost-budget.sh."
    ;;
  *)
    lab_log_error "Invalid BUDGET_VERIFY_MODE: ${BUDGET_VERIFY_MODE} (use console or cli)"
    exit 2
    ;;
esac

lab_log_info "Verify target: ${BUDGET_VERIFY_MODE} (${VERIFY_MODE_LABEL})"
lab_require_commands aws jq awk
require_env BUDGET_EMAIL

budget_resolve_verify_expectations "$BUDGET_VERIFY_MODE" || exit 1
if [[ -z "${VERIFY_EXPECT_NAME:-}" || -z "${VERIFY_EXPECT_LIMIT:-}" ]]; then
  lab_log_error "Set ${VERIFY_NAME_ENV_KEY} and ${VERIFY_LIMIT_ENV_KEY} (or BUDGET_NAME / BUDGET_LIMIT_USD) in .env"
  exit 1
fi

BUDGET_NAME="$VERIFY_EXPECT_NAME"
BUDGET_LIMIT_USD="$VERIFY_EXPECT_LIMIT"

init_aws_cli
if ! ensure_aws_session; then
  po_budget_run_context "$VERIFY_BANNER" "Lab 1 · budgets · ${BUDGET_VERIFY_MODE}"
  lab_preflight_failed "Fix AWS credentials (Lab 2 CLI runbook) and re-run."
fi

po_budget_run_context "$VERIFY_BANNER" "Lab 1 · budgets · ${BUDGET_VERIFY_MODE}"

lab_set_phase "Resolve AWS identity"
ACCOUNT_ID="$(aws_account_id)"
ARN="$(aws_caller_arn)"

OVERALL="VERIFIED"
DETAIL="Budget matches lab configuration."
FAILURES=0
WARNINGS=0

po_section "Local configuration (.env)"
po_table_header
po_row "Verify target" "OK" "${BUDGET_VERIFY_MODE} — ${VERIFY_MODE_LABEL}"
po_row "Config file" "OK" "${LAB_CONFIG_FILE}"
po_row "Budget name" "OK" "${BUDGET_NAME} (${VERIFY_NAME_ENV_KEY} or BUDGET_NAME)"
po_row "Expected limit" "OK" "USD ${BUDGET_LIMIT_USD} (${VERIFY_LIMIT_ENV_KEY} or BUDGET_LIMIT_USD)"
po_row "Expected email" "OK" "$(po_mask_email "${BUDGET_EMAIL}")"
po_row "AWS account" "OK" "$(po_mask_account "$ACCOUNT_ID")"
po_row "Caller" "OK" "${ARN##*:user/}"

if [[ "$BUDGET_VERIFY_MODE" == "console" && "$BUDGET_NAME" == *-cli ]]; then
  po_row "Name vs target" "WARN" "console verify but name looks like CLI budget"
  WARNINGS=$((WARNINGS + 1))
fi

po_section "Budget resource (AWS)"
po_table_header

lab_set_phase "Fetch budget (DescribeBudget)"
BUDGET_JSON=""
if BUDGET_JSON="$(budget_describe_json "$ACCOUNT_ID" "$BUDGET_NAME" 2>&1)"; then
  po_row "Budget exists" "OK" "${BUDGET_NAME}"
else
  LAB_AWS_LAST_ERROR="${BUDGET_JSON//$'\n'/ }"
  po_row "Budget exists" "FAIL" "not found in account"
  po_row "DescribeBudget" "FAIL" "$(lab_aws_first_line | cut -c1-72)"
  po_outcome "FAILED" "${VERIFY_ON_MISSING}"
  exit 1
fi

BUDGET_TYPE="$(jq -r '.Budget.BudgetType // empty' <<<"$BUDGET_JSON")"
TIME_UNIT="$(jq -r '.Budget.TimeUnit // empty' <<<"$BUDGET_JSON")"
ACTUAL_LIMIT="$(jq -r '.Budget.BudgetLimit.Amount // empty' <<<"$BUDGET_JSON")"
LIMIT_UNIT="$(jq -r '.Budget.BudgetLimit.Unit // empty' <<<"$BUDGET_JSON")"
SPEND_AMOUNT="$(jq -r '.Budget.CalculatedSpend.Amount // "0"' <<<"$BUDGET_JSON")"
SPEND_UNIT="$(jq -r '.Budget.CalculatedSpend.Unit // "USD"' <<<"$BUDGET_JSON")"
LAST_UPDATED="$(jq -r '.Budget.LastUpdatedTime // empty' <<<"$BUDGET_JSON")"
PERIOD_START="$(jq -r '.Budget.TimePeriod.Start // empty' <<<"$BUDGET_JSON")"
PERIOD_END="$(jq -r '.Budget.TimePeriod.End // empty' <<<"$BUDGET_JSON")"

if [[ "$BUDGET_TYPE" == "COST" ]]; then
  po_row "Budget type" "OK" "COST"
else
  po_row "Budget type" "FAIL" "${BUDGET_TYPE:-unknown}"
  FAILURES=$((FAILURES + 1))
fi

if [[ "$TIME_UNIT" == "MONTHLY" ]]; then
  po_row "Time unit" "OK" "MONTHLY"
else
  po_row "Time unit" "FAIL" "${TIME_UNIT:-unknown}"
  FAILURES=$((FAILURES + 1))
fi

if [[ "$LIMIT_UNIT" == "USD" ]] && budget_amount_equal "$ACTUAL_LIMIT" "$BUDGET_LIMIT_USD"; then
  po_row "Monthly limit" "OK" "USD ${ACTUAL_LIMIT} (matches .env)"
else
  po_row "Monthly limit" "FAIL" "AWS USD ${ACTUAL_LIMIT} vs expected USD ${BUDGET_LIMIT_USD}"
  po_row "Fix limit drift" "WARN" "Set ${VERIFY_LIMIT_ENV_KEY}=${ACTUAL_LIMIT} or re-run update"
  FAILURES=$((FAILURES + 1))
fi

po_row "Calculated spend" "OK" "${SPEND_UNIT} ${SPEND_AMOUNT} (current period)"
if [[ "$SPEND_AMOUNT" == "0" || "$SPEND_AMOUNT" == "0.0" ]]; then
  po_row "Threshold alerts" "OK" "no spend yet — alert emails fire at 85%/100%, not on create"
fi
if [[ -n "$PERIOD_START" && -n "$PERIOD_END" ]]; then
  po_row "Budget period" "OK" "${PERIOD_START} → ${PERIOD_END}"
fi
if [[ -n "$LAST_UPDATED" ]]; then
  po_row "Last updated" "OK" "${LAST_UPDATED}"
fi

po_section "Alert notifications (AWS)"
po_table_header

lab_set_phase "Fetch notifications (DescribeNotificationsForBudget)"
NOTIF_JSON=""
if ! NOTIF_JSON="$(budget_notifications_json "$ACCOUNT_ID" "$BUDGET_NAME" 2>&1)"; then
  LAB_AWS_LAST_ERROR="$NOTIF_JSON"
  po_row "Notifications list" "FAIL" "$(lab_aws_first_line)"
  po_outcome "FAILED" "Could not read budget notifications."
  exit 1
fi

NOTIF_COUNT="$(jq '.Notifications | length' <<<"$NOTIF_JSON")"
if [[ "$NOTIF_COUNT" -ge 3 ]]; then
  po_row "Notification count" "OK" "${NOTIF_COUNT} defined"
else
  po_row "Notification count" "WARN" "${NOTIF_COUNT} (lab expects 3)"
  WARNINGS=$((WARNINGS + 1))
fi

check_notification() {
  local ntype="$1"
  local threshold="$2"
  local label="$3"
  local match
  match="$(jq -r --arg t "$ntype" --argjson th "$threshold" '
    [.Notifications[]
      | select(.NotificationType == $t
        and ((.Threshold | tonumber) == $th))
    ] | length
  ' <<<"$NOTIF_JSON")"
  if [[ "$match" -ge 1 ]]; then
    po_row "$label" "OK" "${ntype} ≥ ${threshold}%"
  else
    po_row "$label" "FAIL" "missing ${ntype} ${threshold}%"
    FAILURES=$((FAILURES + 1))
  fi
}

check_notification "ACTUAL" 85 "Alert: actual 85%"
check_notification "ACTUAL" 100 "Alert: actual 100%"
check_notification "FORECASTED" 100 "Alert: forecast 100%"

po_section "Email subscribers"
po_table_header

lab_set_phase "Fetch notification subscribers"
EMAIL_FOUND=0
while IFS='|' read -r ntype cop thresh thtype; do
  [[ -z "$ntype" ]] && continue
  notif_arg="NotificationType=${ntype},ComparisonOperator=${cop},Threshold=${thresh%.*},ThresholdType=${thtype}"
  sub_json=""
  if sub_json="$(aws "${AWS_PROFILE_ARGS[@]}" budgets describe-subscribers-for-notification \
    --account-id "$ACCOUNT_ID" \
    --budget-name "$BUDGET_NAME" \
    --notification "$notif_arg" \
    --output json 2>&1)"; then
    while IFS= read -r addr; do
      [[ -z "$addr" || "$addr" == "null" ]] && continue
      if [[ "${addr,,}" == "${BUDGET_EMAIL,,}" ]]; then
        EMAIL_FOUND=1
      fi
      po_row "Subscriber (${ntype} ${thresh%.*}%)" "OK" "$(po_mask_email "$addr")"
    done < <(jq -r '.Subscribers[]? | select(.SubscriptionType=="EMAIL") | .Address' <<<"$sub_json")
  else
    LAB_AWS_LAST_ERROR="$sub_json"
    lab_log_warn "Subscribers for ${notif_arg}: $(lab_aws_first_line)"
    po_row "Subscribers (${ntype} ${thresh%.*}%)" "WARN" "could not list"
    WARNINGS=$((WARNINGS + 1))
  fi
done < <(jq -r '.Notifications[]
  | "\(.NotificationType)|\(.ComparisonOperator)|\(.Threshold)|\(.ThresholdType // "PERCENTAGE")"' <<<"$NOTIF_JSON")

if [[ "$EMAIL_FOUND" -eq 1 ]]; then
  po_row "Matches .env email" "OK" "$(po_mask_email "${BUDGET_EMAIL}")"
else
  po_row "Matches .env email" "WARN" "no EMAIL subscriber equal to BUDGET_EMAIL"
  WARNINGS=$((WARNINGS + 1))
fi

lab_set_phase "Check SNS email subscription status"
PENDING_COUNT=0
if PENDING_COUNT="$(budget_sns_email_pending_count "$BUDGET_EMAIL" 2>/dev/null)"; then
  if [[ "$PENDING_COUNT" -gt 0 ]]; then
    po_row "SNS confirmation" "FAIL" "${PENDING_COUNT} pending — confirm AWS email link"
    FAILURES=$((FAILURES + 1))
  else
    po_row "SNS confirmation" "OK" "no PendingConfirmation for this address"
  fi
else
  po_row "SNS confirmation" "WARN" "could not list SNS subscriptions"
  WARNINGS=$((WARNINGS + 1))
fi

po_row "Inbox search" "WARN" "AWS Budgets / Amazon Web Services — not sent until thresholds"

if [[ "$FAILURES" -gt 0 ]]; then
  OVERALL="FAILED"
  DETAIL="${FAILURES} check(s) failed — confirm SNS email, fix .env keys, or re-run update."
elif [[ "$WARNINGS" -gt 0 ]]; then
  OVERALL="VERIFIED"
  DETAIL="${WARNINGS} warning(s) — review WARN rows."
else
  OVERALL="VERIFIED"
  DETAIL="Budget '${BUDGET_NAME}' matches .env (${BUDGET_VERIFY_MODE} verify)."
fi

po_outcome "$OVERALL" "$DETAIL"
if [[ "$OVERALL" == "FAILED" ]]; then
  exit 1
fi
exit 0
