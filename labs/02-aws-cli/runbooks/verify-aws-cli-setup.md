# Verify AWS CLI setup (script)

## Outcome

**`verify-aws-cli-setup.sh`** confirms CLI v2, profile **`lab-admin`**, region, and **`sts get-caller-identity`**.

## Prerequisites

- [Install and configure the AWS CLI](install-and-configure-aws-cli.md)

## Steps

Optional: `cp labs/02-aws-cli/config/cli.env.example labs/02-aws-cli/config/.env` (otherwise profile defaults to **lab-admin**).

```bash
bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh
```

Watch **stderr** for phased `INFO`/`ERROR` lines while the summary table prints on **stdout**.

- **Verify:** Summary section shows **`OUTCOME`** **`VERIFIED`** and exit code **0**. The script prints a formatted check table (see [scripts README](../scripts/README.md#script-output)).

## Last verified

- **Date:** 2026-09-24 (CLI 2.37.0, profile lab-admin, us-east-2)
- **Region:** from profile (e.g. **us-east-2**)
