# Verify a monthly cost budget (CLI)

## Outcome

You know whether the **CLI** budget named in **`BUDGET_NAME`** exists in AWS and matches **`config/.env`** (limit, alerts, email).

## Prerequisites

- [Create monthly cost budget (CLI)](create-monthly-cost-budget-cli.md)
- [Lab 2 — Install and configure the AWS CLI](../../02-aws-cli/runbooks/install-and-configure-aws-cli.md)
- **`config/.env`**: **`BUDGET_NAME_CLI`** / **`BUDGET_LIMIT_USD_CLI`** (or **`BUDGET_NAME`** / **`BUDGET_LIMIT_USD`**) and **`BUDGET_EMAIL`**

## Steps

Point **`BUDGET_NAME`** at your CLI budget (e.g. `lab-monthly-spend-cli`), then:

```bash
bash labs/01-account-and-iam/scripts/budgets/verify-cli-monthly-cost-budget.sh
```

Equivalent:

```bash
bash labs/01-account-and-iam/scripts/budgets/verify-monthly-cost-budget.sh cli
```

- **Verify:** Summary **`OUTCOME`** **`VERIFIED`** or **`FAILED`**. Table row **Verify target** shows **`cli`**.

For the **console** budget, see [Verify console budget (CLI)](verify-console-monthly-cost-budget-cli.md).

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `Budget exists` **FAIL** | Wrong `BUDGET_NAME` or create script not run yet |
| `Monthly limit` **FAIL** | Run [update-monthly-cost-budget-cli.md](update-monthly-cost-budget-cli.md) or fix `.env` |
| **`SNS confirmation`** **WARN** | Confirm budget/SNS email; threshold alerts are separate from the confirmation message |

## Related

[Create](create-monthly-cost-budget-cli.md) · [Update](update-monthly-cost-budget-cli.md) · [Delete](delete-monthly-cost-budget-cli.md)

## Last verified

- **Date:** 2026-09-24
- **Region:** N/A (Budgets API)
- **Notes:** `verify-cli-monthly-cost-budget.sh` **VERIFIED** for `lab-monthly-spend-cli` / USD 11.
