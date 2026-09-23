#!/usr/bin/env bash
# Verify CLI-created monthly cost budget (create runbook). Same .env keys; target=cli.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/verify-monthly-cost-budget.sh" cli
