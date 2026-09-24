# Update a monthly cost budget limit (CLI)

## Outcome

The budget you select has a new **monthly USD limit**. Email alerts are **not** changed by this script (recreate the budget to change `BUDGET_EMAIL`).

## Prerequisites

- [Create monthly cost budget (CLI)](create-monthly-cost-budget-cli.md)
- [Lab 2 CLI install](../../02-aws-cli/runbooks/install-and-configure-aws-cli.md)

## Steps

In a **terminal**:

```bash
bash labs/01-account-and-iam/scripts/budgets/update-monthly-cost-budget.sh
```

1. Pick a budget by number (`1`, `2`, …).
2. **Type** the new monthly limit in USD when prompted (or `q` to cancel).

Automation / no TTY:

```bash
bash labs/01-account-and-iam/scripts/budgets/update-monthly-cost-budget.sh \
  --name lab-monthly-spend-cli --limit 20
```

Or set **`BUDGET_LIMIT_USD`** in `.env` and run without a TTY (CI).

- **Verify:** **`OUTCOME`** **`UPDATED`** (or **`NO-OP`** if the limit you entered matches AWS already).

## Teardown

[Delete monthly cost budget (CLI)](delete-monthly-cost-budget-cli.md)

## Last verified

- **Date:** 2026-09-24
- **Region:** N/A (Budgets API)
- **Notes:** `update-monthly-cost-budget.sh --name lab-monthly-spend-cli --limit 12` then `--limit 11`; **UPDATED** both times; non-interactive `.env` sync prompt skipped (no TTY).
