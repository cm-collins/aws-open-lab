# Labs 1 and 2 — completion checklist

Use this after you have a real AWS account. Console guardrails first, then CLI, then optional budget automation.

## Lab 1 — Account and IAM (required)

Follow [Lab 1 runbooks](../labs/01-account-and-iam/runbooks/README.md) **1–5** in order:

1. [Create an AWS account](../labs/01-account-and-iam/runbooks/create-aws-account.md)
2. [Enable MFA on the root user](../labs/01-account-and-iam/runbooks/enable-root-mfa.md)
3. [Set a billing alert](../labs/01-account-and-iam/runbooks/billing-alert.md) — **one console budget is enough** for guardrails
4. [Create an admin IAM user](../labs/01-account-and-iam/runbooks/create-admin-iam-user.md) — **`lab-admin`**
5. [Enable IAM billing access via a group](../labs/01-account-and-iam/runbooks/enable-iam-billing-via-group.md) — if **Cost and usage** shows Access denied

**Lab 1 done when:**

- Root has MFA; daily work uses **`lab-admin`**, not root.
- A monthly cost budget exists (runbook 3) and alert email is **confirmed** (SNS).
- **`lab-admin`** can open billing pages without Access denied (runbook 5).

## Lab 2 — AWS CLI (required before Lab 3)

1. [Install and configure the AWS CLI](../labs/02-aws-cli/runbooks/install-and-configure-aws-cli.md) — profile **`lab-admin`**
2. [Verify CLI setup](../labs/02-aws-cli/runbooks/verify-aws-cli-setup.md):

   ```bash
   export AWS_PROFILE=lab-admin
   bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh
   ```

**Lab 2 done when:** verify script **`OUTCOME`** is **`VERIFIED`**.

## Optional — Lab 1 budget scripts (after Lab 2)

Teaches the same guardrail via bash. Use a **separate budget name** from the console budget so verify scripts do not conflict.

| Step | Runbook |
| --- | --- |
| Create | [create-monthly-cost-budget-cli.md](../labs/01-account-and-iam/runbooks/create-monthly-cost-budget-cli.md) |
| Verify CLI budget | [verify-monthly-cost-budget-cli.md](../labs/01-account-and-iam/runbooks/verify-monthly-cost-budget-cli.md) |
| Verify console budget | [verify-console-monthly-cost-budget-cli.md](../labs/01-account-and-iam/runbooks/verify-console-monthly-cost-budget-cli.md) — set **`BUDGET_NAME_CONSOLE`** to match runbook 3 |
| Update limit | [update-monthly-cost-budget-cli.md](../labs/01-account-and-iam/runbooks/update-monthly-cost-budget-cli.md) |
| Delete CLI budget | [delete-monthly-cost-budget-cli.md](../labs/01-account-and-iam/runbooks/delete-monthly-cost-budget-cli.md) |

Suggested names in [`budgets.env.example`](../labs/01-account-and-iam/config/budgets.env.example): console **`lab-monthly-spend`**, CLI **`lab-monthly-spend-cli`**.

## Before Lab 3 (networking)

Pick a **home region** in `~/.aws/config` for profile **`lab-admin`** (for example **`us-east-2`** or **`eu-west-1`**). Lab 1 is global; VPC and EC2 in Lab 3 are regional.

## Security note (CLI keys vs MFA)

Lab 1 enables **MFA on root** and (optionally) on **`lab-admin`** for console sign-in. The CLI uses **long-lived access keys** in `~/.aws/credentials`. Treat them like passwords: do not commit them, rotate if exposed, and prefer short-lived credentials (SSO, IAM Identity Center) in production. See [Install and configure the AWS CLI — Security](../labs/02-aws-cli/runbooks/install-and-configure-aws-cli.md#security-access-keys-and-mfa).
