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

## Development container (optional)

For a consistent Linux shell with **AWS CLI v2**, **gh**, **Terraform**, **CDK**, **jq**, **uv/uvx** (MCP), and related tools, reopen this repo in a [dev container](.devcontainer/README.md). Host **`~/.aws`** is mounted in; lab **`config/.env`** files are scaffolded on first build. Run `bash .devcontainer/verify-tools.sh` after rebuild.

## Path

| Order | Lab | You will be able to |
| --- | --- | --- |
| 1 | [Account and IAM](labs/01-account-and-iam/) | Sign in safely and grant the least access a task needs |
| 2 | [AWS CLI and bash automation](labs/02-aws-cli/) | Install and verify the CLI (budget scripts live in Lab 1) |
| 3 | Networking | Build a VPC with public and private subnets |
| 4 | Compute | Run a virtual machine and reach it on purpose |
| 5 | Storage | Store and share files without making the bucket public by accident |
| 6 | Infrastructure as code | Recreate a lab from a file instead of the console |

Labs marked “not written yet” land when someone has run them on a real account. Labs **1** and **2** are ready; use [docs/labs-1-2-checklist.md](docs/labs-1-2-checklist.md) to confirm you are done before Lab 3.

## If you already know another cloud

The ideas carry over. The names and the console do not. Each doc names the closest equivalent in Azure where that helps, then sticks to AWS for the steps.

## Cost

Your account, your bill. Before you start a lab:

- Prefer the Free Tier.
- Set a billing alarm in the lab 1 account.
- Delete what the lab created before you close the laptop.

## Contributing

Corrections and new labs are welcome. A good lab has a goal, the steps you actually followed, what it cost, and what to delete. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Original lab content, runbooks, and scripts in this repository are licensed under the [MIT License](LICENSE). AWS Agent Toolkit skills are installed locally, not vendored in git — see [NOTICE.md](NOTICE.md).
