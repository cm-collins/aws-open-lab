# Lab 1 runbooks

Do these in order. Each runbook is one task with a clear done state.

| # | Runbook | Outcome |
| --- | --- | --- |
| 1 | [Create an AWS account](create-aws-account.md) | Root user and sign-in |
| 2 | [Enable MFA on the root user](enable-root-mfa.md) | Root MFA |
| 3 | [Set a billing alert](billing-alert.md) | Console budget + email alerts |
| 4 | [Create an admin IAM user](create-admin-iam-user.md) | **`lab-admin`** for daily work |
| 5 | [Enable IAM billing access via a group](enable-iam-billing-via-group.md) | Cost and usage for IAM |

### Optional — budgets via CLI (after Lab 2)

Requires [Lab 2 CLI install](../../02-aws-cli/runbooks/install-and-configure-aws-cli.md).

| # | Runbook | Scripts |
| --- | --- | --- |
| 6 | [Create monthly cost budget (CLI)](create-monthly-cost-budget-cli.md) | `scripts/budgets/create-…` |
| 7 | [Update monthly cost budget (CLI)](update-monthly-cost-budget-cli.md) | `scripts/budgets/update-…` |
| 8 | [Delete monthly cost budget (CLI)](delete-monthly-cost-budget-cli.md) | `scripts/budgets/delete-…` |
| 9 | [Verify CLI budget](verify-monthly-cost-budget-cli.md) | `verify-cli-monthly-cost-budget.sh` |
| — | [Verify console budget (optional)](verify-console-monthly-cost-budget-cli.md) | `verify-console-monthly-cost-budget.sh` |

When runbooks **1–5** are done, see the [lab README](../README.md).
