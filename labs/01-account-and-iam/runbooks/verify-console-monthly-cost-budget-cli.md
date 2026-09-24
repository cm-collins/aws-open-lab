# Verify a monthly cost budget (console)

## Outcome

You know whether the **console template** budget in **`BUDGET_NAME`** matches **`config/.env`** (limit, 85/100/forecast alerts, email).

## Prerequisites

- [Set a billing alert](billing-alert.md) (Monthly cost budget template)
- [Lab 2 — Install and configure the AWS CLI](../../02-aws-cli/runbooks/install-and-configure-aws-cli.md)
- **`config/.env`**: set **`BUDGET_NAME_CONSOLE`** and **`BUDGET_LIMIT_USD_CONSOLE`** (or **`BUDGET_NAME`** / **`BUDGET_LIMIT_USD`**) to match the console budget, plus **`BUDGET_EMAIL`**

## Steps

```bash
bash labs/01-account-and-iam/scripts/budgets/verify-console-monthly-cost-budget.sh
```

Equivalent:

```bash
bash labs/01-account-and-iam/scripts/budgets/verify-monthly-cost-budget.sh console
```

- **Verify:** **Verify target** row shows **`console`**. **`OUTCOME`** **`VERIFIED`** when AWS matches `.env`.

**Important:** **`BUDGET_NAME_CONSOLE`** and **`BUDGET_LIMIT_USD_CONSOLE`** must match the budget you created in [billing-alert.md](billing-alert.md). If you only use the CLI budget, skip this runbook or create the console budget first.

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| **`Budget exists`** **FAIL** | Console budget name in `.env` does not match AWS (typo or only CLI budget exists) |
| **`Monthly limit`** **FAIL** | Console limit changed in the console; update `.env` or edit the budget |

## Related

[Verify CLI budget](verify-monthly-cost-budget-cli.md) · [billing-alert.md](billing-alert.md)

## Last verified

- **Date:** 2026-09-24
- **Region:** N/A (Budgets API)
- **Notes:** Script exercised; **FAILED** as expected when no console budget named `lab-monthly-spend` exists (CLI-only account). Passes when `.env` matches runbook 3.
