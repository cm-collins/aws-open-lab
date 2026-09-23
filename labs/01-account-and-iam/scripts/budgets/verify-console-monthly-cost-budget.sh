#!/usr/bin/env bash
# Verify console-created monthly cost budget (billing-alert runbook). Same .env keys; target=console.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/verify-monthly-cost-budget.sh" console
