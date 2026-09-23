# aws-open-lab

A public lab for learning AWS by doing it. Read a short note, build the thing, then write down what you learned so the next person starts further along.

This is a shared notebook, not a certification dump. Labs stay small enough to finish in one sitting and cheap enough to turn off when you are done.

## How to use it

1. Pick the next unfinished lab in [labs](labs/).
2. Read the matching note in [docs](docs/) if the ideas are new.
3. Follow the runbooks in that lab’s `runbooks/` folder, in order.
4. Build it in your own AWS account.
5. Add what surprised you: fix a runbook step or bump **Last verified** in a pull request.

Work in the AWS Free Tier when you can. Stop or delete resources at the end of each lab. Each runbook says what to tear down.

## Path

| Order | Lab | You will be able to |
| --- | --- | --- |
| 1 | [Account and IAM](labs/01-account-and-iam/) | Sign in safely and grant the least access a task needs |
| 2 | [AWS CLI and bash automation](labs/02-aws-cli/) | Configure the CLI and script guardrails (e.g. budgets) — [planned](docs/planned-aws-cli-lab.md) |
| 3 | Networking | Build a VPC with public and private subnets |
| 4 | Compute | Run a virtual machine and reach it on purpose |
| 5 | Storage | Store and share files without making the bucket public by accident |
| 6 | Infrastructure as code | Recreate a lab from a file instead of the console |

Labs marked planned or “not written yet” land when someone has run them on a real account. Lab 2 is stubbed so CLI/bash work has a clear home before scripts are added.

## If you already know another cloud

The ideas carry over. The names and the console do not. Each doc names the closest equivalent in Azure where that helps, then sticks to AWS for the steps.

## Cost

Your account, your bill. Before you start a lab:

- Prefer the Free Tier.
- Set a billing alarm in the lab 1 account.
- Delete what the lab created before you close the laptop.

## Contributing

Corrections and new labs are welcome. A good lab has a goal, the steps you actually followed, what it cost, and what to delete. See [CONTRIBUTING.md](CONTRIBUTING.md).
