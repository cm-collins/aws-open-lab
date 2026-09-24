# Delete a monthly cost budget (CLI)

## Outcome

Budget **`BUDGET_NAME`** is removed (or already absent).

## Prerequisites

- [Lab 2 CLI install](../../02-aws-cli/runbooks/install-and-configure-aws-cli.md)
- **`BUDGET_NAME`** in `labs/01-account-and-iam/config/.env`

## Steps

```bash
bash labs/01-account-and-iam/scripts/budgets/delete-monthly-cost-budget.sh
```

On a **terminal** (interactive **TTY** — your normal shell window), the script lists every budget with a **number** (`1`, `2`, …). Type the number to delete (or `q` to cancel). One budget: press **Enter** to confirm.

Non-interactive (CI or scripts):

```bash
bash labs/01-account-and-iam/scripts/budgets/delete-monthly-cost-budget.sh --name lab-monthly-spend-cli
# or set BUDGET_NAME in .env
```

- **Verify:** Summary **`OUTCOME`** **`DELETED`** or **`NO-OP`** if the budget was already absent or you cancelled.

Console budgets from [billing-alert.md](billing-alert.md) can also be deleted in the console if you did not create them with this script.

## Last verified

- **Date:** 2026-09-24
- **Region:** N/A (Budgets API)
- **Notes:** `--name` on missing budget → **NO-OP**; ephemeral `lab-open-lab-delete-test` create + **DELETED** via script (non-interactive).
