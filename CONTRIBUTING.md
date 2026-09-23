# Contributing

Add something you have done yourself. By contributing, you agree that your contributions are licensed under the repository [MIT License](LICENSE).

Do not commit secrets, `.env` files, keys, or account-specific IDs. Use `*.env.example` templates only.

## A note

Put it in `docs/`. Explain one idea, what it is for, and the AWS name for it. If you know the Azure equivalent, add one line for people crossing over. Skip long console click-paths; link the lab runbook that uses the idea.

## A lab

Create `labs/NN-short-name/` with:

- **`README.md`** — goal, prerequisites, link to `runbooks/`, final check, cost, clean up
- **`runbooks/`** — one markdown file per completable task (see template)

Copy [labs/runbooks/TEMPLATE.md](labs/runbooks/TEMPLATE.md) for each new runbook. Use verb-led filenames (`enable-root-mfa.md`, not `mfa.md`).

Add `runbooks/README.md` as a numbered index table linking each runbook and its outcome.

Optional **`scripts/`** under a lab: bash helpers that match a verified runbook (env vars + example config, no secrets).

When a script **creates** something in AWS, add **`update-*`** and **`delete-*`** in the **same lab** as the resource (e.g. budgets under `labs/01-account-and-iam/scripts/budgets/`). **Lab 2** scripts are CLI tooling only — see [docs/lab-2-script-roadmap.md](docs/lab-2-script-roadmap.md).

Each runbook should include:

- **Outcome** — one sentence
- **Prerequisites** — prior runbooks, region, time, cost
- **Steps** — numbered; **Verify** after important steps
- **Troubleshooting** — a few real failures you hit
- **Teardown** — delete vs keep
- **Last verified** — date and region

Update the path table in the root README when you add a lab.

## Leave out

Keys, account IDs, passwords, `.pem` files, Terraform state, and screenshots that show a secret or an account number.
