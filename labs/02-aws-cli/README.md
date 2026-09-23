# Lab 2 — AWS CLI and bash automation

**Status:** Planned — not ready to run yet.

**Goal (draft).** Install the AWS CLI, authenticate with a lab IAM profile, and recreate account guardrails (starting with a monthly cost budget) using bash scripts instead of the console.

**Prerequisites.** Finish [Lab 1](../01-account-and-iam/) (IAM user with MFA). Complete [Set a billing alert](../01-account-and-iam/runbooks/billing-alert.md) in the console first so you know what the script will automate.

## Runbooks

Not written yet. Planned index:

1. Install and configure the AWS CLI (profile, `aws sts get-caller-identity`)
2. Create a monthly cost budget from the CLI (bash + JSON)

Full plan: [docs/planned-aws-cli-lab.md](../../docs/planned-aws-cli-lab.md)

## Scripts

See [scripts/README.md](scripts/README.md). Implementation lands when the runbooks are verified.
