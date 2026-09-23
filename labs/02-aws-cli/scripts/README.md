# Lab 2 scripts (planned)

Bash helpers for tasks you first do in the console during Lab 1.

## Planned scripts

| Script | Purpose |
| --- | --- |
| `create-monthly-cost-budget.sh` | Idempotent monthly cost budget with the same notification thresholds as the Lab 1 console template |

Supporting files (planned):

- `../config/budgets/monthly-cost-budget.example.json` — budget document passed to `aws budgets create-budget`
- `../config/.env.example` — `BUDGET_NAME`, `BUDGET_LIMIT_USD`, `BUDGET_EMAIL`, optional `AWS_PROFILE`

## Usage (future)

Documented in the runbook. Expect:

```bash
export AWS_PROFILE=lab-admin
# shellcheck create-monthly-cost-budget.sh
./create-monthly-cost-budget.sh
```

Do not commit `.env`, access keys, or account-specific JSON with real emails until sanitized.

## Contributing

Implement only after the matching runbook is tested. Match Lab 1 behavior before adding extras.
