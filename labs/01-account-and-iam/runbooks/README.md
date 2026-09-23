# Lab 1 runbooks

Do these in order. Each runbook is one task with a clear done state.

| # | Runbook | Outcome |
| --- | --- | --- |
| 1 | [Create an AWS account](create-aws-account.md) | You have a root user and can sign in |
| 2 | [Enable MFA on the root user](enable-root-mfa.md) | Root sign-in requires your second factor |
| 3 | [Set a billing alert](billing-alert.md) | You get notified before spend surprises you |
| 4 | [Create an admin IAM user](create-admin-iam-user.md) | Daily work uses IAM, not root |
| 5 | [Enable IAM billing access via a group](enable-iam-billing-via-group.md) | **`lab-admin`** can view billing and Cost and usage (recommended) |

Runbook **5** requires **`lab-admin`** (runbook 4). Use **root** only for the one-time activation in runbook 5 Part A.

When all required runbooks are done, see the [lab README](../README.md) for the final check.
