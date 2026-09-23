# Planned lab — AWS CLI and bash automation

**Status:** Not written yet. This page records the plan so contributors can align before the lab is built.

## Why this lab exists

Lab 1 runbooks use the console so you see what a budget or IAM object *is*. This lab adds the same outcomes from the terminal: repeatable setup, version control, and a path toward infrastructure as code.

If you know Azure CLI (`az`), the pattern is familiar: configure credentials, run commands, script common tasks.

## Planned placement

| Order | Lab | Notes |
| --- | --- | --- |
| 1 | [Account and IAM](../labs/01-account-and-iam/) | Console-first guardrails |
| 2 | [AWS CLI](../labs/02-aws-cli/) | Install CLI, profiles, bash scripts |
| 3 | Networking | VPC (console or CLI later) |
| 4 | Compute | EC2 |
| 5 | Storage | S3 |
| 6 | Infrastructure as code | Terraform or CloudFormation |

## Planned outcomes (Lab 2)

After the lab runbooks, you should be able to:

- Install and verify the AWS CLI v2 on Linux (bash).
- Configure a named **profile** for your lab IAM user (no access keys in git).
- Call **`aws sts get-caller-identity`** and interpret account and ARN.
- Create the same **monthly cost budget** as [Set a billing alert](../labs/01-account-and-iam/runbooks/billing-alert.md) using **`aws budgets create-budget`** and notification definitions (85% / 100% actual, 100% forecast).
- Re-run scripts safely: check with **`aws budgets describe-budgets`** before create.

## Planned repo layout

```text
labs/02-aws-cli/
  README.md
  runbooks/
    install-and-configure-aws-cli.md
    create-monthly-cost-budget-cli.md
  scripts/
    README.md
    create-monthly-cost-budget.sh
    lib/common.sh                    # optional: logging, require_env
  config/
    budgets/
      monthly-cost-budget.example.json
    .env.example                     # BUDGET_NAME, BUDGET_LIMIT_USD, BUDGET_EMAIL
```

Scripts will use **`set -euo pipefail`**, read settings from environment variables, and document required IAM actions (for example `budgets:CreateBudget`, `budgets:DescribeBudgets`).

## Relationship to Lab 1 billing runbook

| Lab 1 (console) | Lab 2 (CLI) |
| --- | --- |
| Learn thresholds and email confirmation | Same budget, defined in JSON + bash |
| Good first time in a new account | Good for reproducing on a second machine or after teardown |

Email subscribers still must **confirm** AWS notification messages; automation does not skip that step.

## When this becomes “ready”

Per [CONTRIBUTING.md](../CONTRIBUTING.md): someone runs every runbook on a real account, adds **Last verified**, and merges the scripts only after they work against the documented profile and permissions.
