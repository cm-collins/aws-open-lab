#!/usr/bin/env bash
# Verify monthly COST budget. Usage: verify-monthly-cost-budget.sh [console|cli]
# Same .env keys (BUDGET_NAME, BUDGET_LIMIT_USD, BUDGET_EMAIL); target selects context/hints.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

lab_log_info "Starting verify-monthly-cost-budget.sh"

resolve_verify_mode() {
  local arg="${1:-}"
  case "$arg" in
    console | cli)
      printf '%s' "$arg"
      return 0
      ;;
    "")
      if [[ -n "${BUDGET_VERIFY_TARGET:-}" ]]; then
        case "${BUDGET_VERIFY_TARGET}" in
          console | cli) printf '%s' "${BUDGET_VERIFY_TARGET}"; return 0 ;;
          *)
            lab_log_error "Invalid BUDGET_VERIFY_TARGET=${BUDGET_VERIFY_TARGET} (use console or cli)"
            exit 2
            ;;
        esac
      fi
      printf '%s' "cli"
      return 0
      ;;
    -h | --help)
      cat >&2 <<EOF
Usage: $(basename "$0") [console|cli]

  console  Verify the console template budget (runbook: billing-alert).
           Set BUDGET_NAME in .env to that budget (e.g. lab-monthly-spend).

  cli      Verify the CLI-created budget (default; runbook 6).
           Set BUDGET_NAME to your CLI budget (e.g. lab-monthly-spend-cli).

Uses the same keys in labs/01-account-and-iam/config/.env:
  BUDGET_NAME, BUDGET_LIMIT_USD, BUDGET_EMAIL

Optional in .env: BUDGET_VERIFY_TARGET=console|cli (default for this script when no arg).

Dedicated entry points:
  verify-console-monthly-cost-budget.sh
  verify-cli-monthly-cost-budget.sh
EOF
      exit 0
      ;;
    *)
      lab_log_error "Unknown argument: ${arg} (expected console or cli)"
      exit 2
      ;;
  esac
}

BUDGET_VERIFY_MODE="$(resolve_verify_mode "${1:-}")"
# shellcheck source=lib/verify-monthly-cost-budget-core.sh
source "${SCRIPT_DIR}/lib/verify-monthly-cost-budget-core.sh"
