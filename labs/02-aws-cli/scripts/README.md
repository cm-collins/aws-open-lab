# Lab 2 scripts

CLI **tooling** for this lab—not account guardrails. Budget create/update/delete lives in [Lab 1 scripts](../../01-account-and-iam/scripts/).

| Script | Runbook |
| --- | --- |
| `verify-aws-cli-setup.sh` | [Verify AWS CLI setup](../runbooks/verify-aws-cli-setup.md) |

Roadmap: [docs/lab-2-script-roadmap.md](../../docs/lab-2-script-roadmap.md).

## Script output

Scripts use the same premium CLI summaries as Lab 1: banner, check tables, and a **Summary** outcome. See [`labs/shared/scripts/lib/premium-output.sh`](../../shared/scripts/lib/premium-output.sh) and [Lab 1 scripts README](../../01-account-and-iam/scripts/README.md#script-output).

Optional (defaults to `AWS_PROFILE=lab-admin` if missing):

```bash
cp labs/02-aws-cli/config/cli.env.example labs/02-aws-cli/config/.env
```

Run:

```bash
bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh
```

Phased **stderr** logging and **stdout** summary tables match Lab 1 ([`lab-runtime.sh`](../../shared/scripts/lib/lab-runtime.sh)).
