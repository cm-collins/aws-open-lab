# Lab 2 — AWS CLI (plan and layout)

**Status:** **Implemented.** Runbooks and `verify-aws-cli-setup.sh` live in [labs/02-aws-cli](../labs/02-aws-cli/). Budget scripts live under [Lab 1](../labs/01-account-and-iam/scripts/budgets/). Learner checklist: [labs-1-2-checklist.md](labs-1-2-checklist.md).

This file is a historical layout reference; prefer the lab READMEs for day-to-day use.

## Split of responsibilities

| Lab | Console | Scripts |
| --- | --- | --- |
| **1** Account / IAM / billing | Runbooks 1–5 | `scripts/budgets/` (create, update, delete) — needs CLI from Lab 2 |
| **2** CLI | Install + verify runbooks | `verify-aws-cli-setup.sh` (+ [roadmap](lab-2-script-roadmap.md)) |

## Lab 2 layout

```text
labs/02-aws-cli/
  runbooks/
    install-and-configure-aws-cli.md
    verify-aws-cli-setup.md
  scripts/
    verify-aws-cli-setup.sh
  config/
    cli.env.example
```

## Lab 1 budget layout

```text
labs/01-account-and-iam/
  scripts/
    lib/common.sh
    budgets/
      create-monthly-cost-budget.sh
      update-monthly-cost-budget.sh
      delete-monthly-cost-budget.sh
  config/
    budgets.env.example
  runbooks/
    create-monthly-cost-budget-cli.md
    update-monthly-cost-budget-cli.md
    delete-monthly-cost-budget-cli.md
```

## Order learners follow

1. Lab 1 runbooks 1–5 (console)
2. Lab 2 install + verify CLI
3. Lab 1 runbooks 6–8 (budget CLI) — optional automation
