#!/usr/bin/env bash
# Runs once after the dev container is created (not on every start).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo ""
echo "=== AWS Open Lab — dev container setup ==="

lab_env="${REPO_ROOT}/labs/01-account-and-iam/config/.env"
lab_example="${REPO_ROOT}/labs/01-account-and-iam/config/budgets.env.example"
cli_env="${REPO_ROOT}/labs/02-aws-cli/config/.env"
cli_example="${REPO_ROOT}/labs/02-aws-cli/config/cli.env.example"

if [[ ! -f "$lab_env" && -f "$lab_example" ]]; then
  cp "$lab_example" "$lab_env"
  echo "Created labs/01-account-and-iam/config/.env from example (edit before AWS calls)."
fi

if [[ ! -f "$cli_env" && -f "$cli_example" ]]; then
  cp "$cli_example" "$cli_env"
  echo "Created labs/02-aws-cli/config/.env from example."
fi

bash "${REPO_ROOT}/.devcontainer/verify-tools.sh"

echo "Credentials:"
if [[ -f "${HOME}/.aws/credentials" || -f "${HOME}/.aws/config" ]]; then
  echo "  ~/.aws mounted from host"
  if aws sts get-caller-identity --output text 2>/dev/null; then
    echo "  STS OK (profile ${AWS_PROFILE:-default})"
  else
    echo "  STS failed — run Lab 2 runbook or: aws configure --profile lab-admin"
  fi
else
  echo "  No ~/.aws yet — configure on host or inside container (writes to mount)."
fi

if gh auth status >/dev/null 2>&1; then
  echo "  gh: authenticated"
else
  echo "  gh: run 'gh auth login' for PR/commits from the container (optional)"
fi

echo ""
echo "Lab checks:"
echo "  bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh"
echo "  bash labs/01-account-and-iam/scripts/budgets/verify-cli-monthly-cost-budget.sh"
echo ""
echo "Tool list: .devcontainer/README.md"
echo ""
