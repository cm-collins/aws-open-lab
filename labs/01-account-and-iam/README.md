# Lab 1 — Account and IAM

**Goal.** Have an AWS account you can learn in, with MFA on the root user, a billing alert, and a separate administrator you use every day.

**You need.** An email address that is not already an AWS root user, a phone or authenticator app for MFA, and a password manager.

**Region.** Any. This lab does not create regional resources. Pick a **home region** in Lab 2 (`aws configure --profile lab-admin`) before [Lab 3](../README.md) — for example `us-east-2` or `eu-west-1`.

## Console budget vs CLI budget

Runbook **3** creates a **console** monthly cost budget — that alone satisfies the guardrail. Optional runbooks **6–9** (after [Lab 2](../02-aws-cli/)) create a **second** budget via script, usually with a different name (for example console **`lab-monthly-spend`**, CLI **`lab-monthly-spend-cli`**). See [`config/budgets.env.example`](config/budgets.env.example) and [Labs 1–2 checklist](../../docs/labs-1-2-checklist.md).

## Runbooks

Follow the runbooks **in order**:

→ [Runbooks index](runbooks/README.md)

1. [Create an AWS account](runbooks/create-aws-account.md)
2. [Enable MFA on the root user](runbooks/enable-root-mfa.md)
3. [Set a billing alert](runbooks/billing-alert.md)
4. [Create an admin IAM user](runbooks/create-admin-iam-user.md)
5. [Enable IAM billing access via a group](runbooks/enable-iam-billing-via-group.md) — recommended if **Cost and usage** shows Access denied

Concepts: [IAM and the other foundations](../../docs/foundations.md#iam)

**Scripts:** [scripts/](scripts/) — budget create/update/delete (CLI, after [Lab 2](../02-aws-cli/)).

**Next lab:** [AWS CLI and bash automation](../02-aws-cli/) — install and verify the CLI, then optional Lab 1 budget scripts.

## Final check

- Root has MFA.
- A billing alert or budget notification is configured; **SNS email subscription confirmed** (inbox/spam — alerts do not fire until thresholds).
- You can sign in as the IAM user (e.g. **`lab-admin`**) with MFA.
- You understand **why** daily work should not use root ([runbook](runbooks/create-admin-iam-user.md#why-not-use-root-for-daily-work)).
- You are signed in as the IAM user, not root, before starting Lab 2 or later labs.
- (Recommended) **`lab-admin`** is in group **`lab-billing`** and **Cost and usage** on the console home loads without **Access denied**.
- After Lab 2: `bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh` exits **`VERIFIED`** ([checklist](../../docs/labs-1-2-checklist.md)).

## Clean up

Nothing to delete. Keep the account and the IAM user.

## What it cost

Account creation is free. A card is required on the account. These runbooks do not start billable compute.

## Write back

When you finish, open a pull request if a step changed in the console: update the runbook and bump **Last verified** in that file.
