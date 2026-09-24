# Create a monthly cost budget from the CLI

## Outcome

A **monthly cost budget** exists in your account (name from **`BUDGET_NAME`**) with the same three alerts as the [console template](billing-alert.md): actual **85%**, actual **100%**, forecast **100%**, emailed to **`BUDGET_EMAIL`**.

## Prerequisites

- Runbooks **1–5** in this lab (console guardrails first)
- [Lab 2 — Install and configure the AWS CLI](../../02-aws-cli/runbooks/install-and-configure-aws-cli.md) — `export AWS_PROFILE=lab-admin` and **`aws sts get-caller-identity`** show **`lab-admin`**
- **`jq`** installed
- IAM: **`lab-admin`** needs permission to call **AWS Budgets** and **SNS** (Lab 1 **`AdministratorAccess`** is enough). If you tightened policies, add the **`Billing`** job function or budgets actions — see [Enable IAM billing access via a group](enable-iam-billing-via-group.md).
- Time: ~10 minutes

## Steps

1. Create config once (never commit `.env`):

   ```bash
   cp labs/01-account-and-iam/config/budgets.env.example labs/01-account-and-iam/config/.env
   # Edit BUDGET_* and AWS_PROFILE in .env
   ```

2. Run create (the script loads `.env` for you):

   ```bash
   bash labs/01-account-and-iam/scripts/budgets/create-monthly-cost-budget.sh
   ```

   - **Verify:** Summary **`OUTCOME`** is **`CREATED`** (first run) or **`SKIPPED`** (budget already exists). Progress logs go to stderr.

3. Verify from the CLI:

   ```bash
   bash labs/01-account-and-iam/scripts/budgets/verify-cli-monthly-cost-budget.sh
   ```

4. Confirm in console **Billing → Budgets** and confirm notification email if AWS sends one (SNS **Confirm subscription** — same as [billing-alert.md](billing-alert.md)).

## Troubleshooting

| Symptom | Likely cause | What to try |
| --- | --- | --- |
| `AccessDenied` on CreateBudget | IAM missing billing/budget permissions | [enable-iam-billing-via-group.md](enable-iam-billing-via-group.md); attach **`Billing`** or use root once for setup |
| Verify **`SNS confirmation`** **WARN** | Email not confirmed | Confirm SNS message in inbox/spam |
| **`SKIPPED`** (already exists) | Idempotent re-run | Use [update](update-monthly-cost-budget-cli.md) or pick a new **`BUDGET_NAME`** |

## Teardown

[Delete monthly cost budget (CLI)](delete-monthly-cost-budget-cli.md) · [Update limit](update-monthly-cost-budget-cli.md)

## Last verified

- **Date:** 2026-09-24
- **Region:** N/A (Budgets API; profile **us-east-2**)
- **Notes:** `create-monthly-cost-budget.sh` **CREATED** `lab-monthly-spend-cli`; `verify-cli-monthly-cost-budget.sh` **VERIFIED**; CLI 2.37.0, profile **lab-admin**.
