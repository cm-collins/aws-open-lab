# Lab 1 — Account and IAM

**Goal.** Have an AWS account you can learn in, with MFA on the root user, a billing alert, and a separate administrator you use every day.

**You need.** An email address that is not already an AWS root user, a phone or authenticator app for MFA, and a password manager.

**Region.** Any. This lab does not create regional resources. Pick a home region later (for example `eu-west-1`) when labs start creating VPCs and EC2 instances.

## Runbooks

Follow the runbooks **in order**:

→ [Runbooks index](runbooks/README.md)

1. [Create an AWS account](runbooks/create-aws-account.md)
2. [Enable MFA on the root user](runbooks/enable-root-mfa.md)
3. [Set a billing alert](runbooks/billing-alert.md)
4. [Create an admin IAM user](runbooks/create-admin-iam-user.md)

Concepts: [IAM and the other foundations](../../docs/foundations.md#iam)

## Final check

- Root has MFA.
- A billing alert or budget notification is configured.
- You can sign in as the IAM user with MFA.
- You are **not** using the root user for the next lab.

## Clean up

Nothing to delete. Keep the account and the IAM user.

## What it cost

Account creation is free. A card is required on the account. These runbooks do not start billable compute.

## Write back

When you finish, open a pull request if a step changed in the console: update the runbook and bump **Last verified** in that file.
