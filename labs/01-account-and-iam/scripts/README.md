# Lab 1 scripts

Automation for **account guardrails** introduced in Lab 1 runbooks. Console steps stay in `runbooks/`; scripts repeat the same outcomes from the CLI.

## Layout

```text
scripts/
  lib/common.sh          # AWS CLI helpers (profile, account id, budgets)
  budgets/
    create-monthly-cost-budget.sh
    update-monthly-cost-budget.sh
    delete-monthly-cost-budget.sh
    verify-monthly-cost-budget.sh   # verify-monthly-cost-budget.sh [console|cli]
    verify-console-monthly-cost-budget.sh
    verify-cli-monthly-cost-budget.sh
config/
  budgets.env.example    # copy to config/.env
```

## Prerequisites

- Lab 1 runbooks **1–5** (especially [Set a billing alert](../runbooks/billing-alert.md))
- [Lab 2 — Install and configure the AWS CLI](../../02-aws-cli/runbooks/install-and-configure-aws-cli.md) (`aws`, profile **`lab-admin`**)

## Lifecycle

| Script | Runbook |
| --- | --- |
| `budgets/create-monthly-cost-budget.sh` | [Create monthly cost budget (CLI)](../runbooks/create-monthly-cost-budget-cli.md) |
| `budgets/update-monthly-cost-budget.sh` | [Update monthly cost budget (CLI)](../runbooks/update-monthly-cost-budget-cli.md) |
| `budgets/delete-monthly-cost-budget.sh` | [Delete monthly cost budget (CLI)](../runbooks/delete-monthly-cost-budget-cli.md) |
| `budgets/verify-cli-monthly-cost-budget.sh` | [Verify CLI budget](../runbooks/verify-monthly-cost-budget-cli.md) |
| `budgets/verify-console-monthly-cost-budget.sh` | [Verify console budget](../runbooks/verify-console-monthly-cost-budget-cli.md) |
| `budgets/verify-monthly-cost-budget.sh [console\|cli]` | Either target; optional `BUDGET_VERIFY_TARGET` in `.env` |

One-time setup:

```bash
cp labs/01-account-and-iam/config/budgets.env.example labs/01-account-and-iam/config/.env
# edit .env — never commit it
```

Run (scripts load `config/.env` automatically):

```bash
bash labs/01-account-and-iam/scripts/budgets/create-monthly-cost-budget.sh
```

**Delete** and **update** on a TTY show a numbered budget list; pick `1`, `2`, … **Update** then prompts you to **type** the new USD limit (`--limit` / `.env` when not interactive).

## Script output

**stdout** — production-style summary: banner, check tables, **Summary** outcome ([`premium-output.sh`](../../shared/scripts/lib/premium-output.sh); `NO_COLOR=1` to disable color; `PO_UTF8_BOX=1` for Unicode box lines).

**stderr** — phased trail so you always know where the script is: `[INFO] script-name: → phase name`, command execution, and `[ERROR]` with AWS/API text on failure. Unexpected errors print line number and phase; use `LAB_DEBUG=1` for `set -x`.

Shared runtime: [`labs/shared/scripts/lib/lab-runtime.sh`](../../shared/scripts/lib/lab-runtime.sh).
