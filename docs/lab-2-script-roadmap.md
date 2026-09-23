# Lab 2 script roadmap

Lab 2 is **CLI tooling and habits**, not account guardrails. Guardrail scripts (budgets) live under [Lab 1](../labs/01-account-and-iam/scripts/).

## In repo now

| Script | Purpose |
| --- | --- |
| [verify-aws-cli-setup.sh](../labs/02-aws-cli/scripts/verify-aws-cli-setup.sh) | CLI v2, profile, region, `sts get-caller-identity` |

Run after [Install and configure the AWS CLI](../labs/02-aws-cli/runbooks/install-and-configure-aws-cli.md):

```bash
export AWS_PROFILE=lab-admin
bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh
```

## Ideas for later (not implemented)

| Script | Why |
| --- | --- |
| `which-aws-profile.sh` | Print active profile, account, region (debug helper) |
| `check-cli-credentials.sh` | Fail fast before long lab scripts if keys expired |
| `cost-last-7-days.sh` | Tiny Cost Explorer CLI sample (Lab 2 stretch) |

## Later labs

| Lab | Script home |
| --- | --- |
| 1 Account / billing | `labs/01-account-and-iam/scripts/budgets/` |
| 2 CLI | `labs/02-aws-cli/scripts/` — verify, helpers |
| 3+ Networking, EC2, S3 | Each lab’s own `scripts/` with create/update/delete |
