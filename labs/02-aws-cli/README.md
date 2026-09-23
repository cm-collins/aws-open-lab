# Lab 2 — AWS CLI and bash automation

**Status:** Runbooks ready to try — mark **ready** after verify script passes on a real account.

**Goal.** Install and verify the AWS CLI with profile **`lab-admin`**. Use scripts for **CLI hygiene**; use [Lab 1 scripts](../01-account-and-iam/scripts/) for **budgets**.

**Prerequisites.** [Lab 1](../01-account-and-iam/) IAM user **`lab-admin`** with access keys (this lab).

## Runbooks

[runbooks/README.md](runbooks/README.md)

1. [Install and configure the AWS CLI](runbooks/install-and-configure-aws-cli.md)
2. [Verify CLI setup](runbooks/verify-aws-cli-setup.md)

## Scripts

| Path | Purpose |
| --- | --- |
| [scripts/verify-aws-cli-setup.sh](scripts/verify-aws-cli-setup.sh) | CLI v2 + profile + identity check |

Budget automation: [../01-account-and-iam/scripts/budgets/](../01-account-and-iam/scripts/budgets/) (after this lab).

## Structure

```text
labs/
  01-account-and-iam/   # guardrails (console + budgets scripts)
  02-aws-cli/           # CLI install + verify (this lab)
```

See [docs/lab-2-script-roadmap.md](../../docs/lab-2-script-roadmap.md) for planned Lab 2 scripts.

## Final check

- `bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh` succeeds
- Optional: run Lab 1 [create budget CLI](../01-account-and-iam/runbooks/create-monthly-cost-budget-cli.md)
