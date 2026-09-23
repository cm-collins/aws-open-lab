# Cursor skills in this repo

## What is in git

| In repository | Not in git (local sync) |
| --- | --- |
| This README | 24 **AWS Agent Toolkit** skill directories |
| `senior-dotnet-engineer`, `senior-flutter-engineer`, `senior-frontend-engineer` | `amazon-bedrock`, `aws-*`, `launch-with-aws`, etc. |

AWS Agent Toolkit skills are **ignored by git** ([`.gitignore`](../../.gitignore)) so the tree stays small and licensing stays clear. See [NOTICE.md](../../NOTICE.md).

## AWS Agent Toolkit skills (install locally)

From the [AWS Agent Toolkit](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/getting-started.html) default set:

| Skill | Topic |
| --- | --- |
| `signing-in-to-aws` | Account access and sign-in |
| `aws-auth` | Authentication patterns |
| `aws-iam` | IAM roles, policies, pitfalls |
| `aws-security` | Security practices |
| `aws-billing-and-cost-management` | Billing and cost |
| `aws-networking` | VPC and networking |
| `aws-compute` | EC2 and compute |
| `aws-storage` | S3 and storage |
| `aws-database` | RDS and databases |
| `aws-serverless` | Lambda and serverless |
| `aws-containers` | ECS, EKS, containers |
| `aws-deployment` | Deploy patterns |
| `aws-observability` | CloudWatch and observability |
| `setting-up-cloudwatch-observability` | CloudWatch setup |
| `aws-cloudformation` | CloudFormation |
| `aws-cdk` | AWS CDK |
| `aws-messaging-and-streaming` | SQS, SNS, Kinesis |
| `aws-sdk-python-usage` | Python SDK |
| `aws-sdk-js-v3-usage` | JavaScript SDK v3 |
| `aws-sdk-swift-usage` | Swift SDK |
| `amazon-bedrock` | Amazon Bedrock |
| `aws-ai-ml` | AI/ML on AWS |
| `aws-blocks` | AWS Blocks |
| `launch-with-aws` | Launch workflows |

Each skill is a directory with `SKILL.md` and optional `references/`.

## Repo-specific skills (committed)

| Skill | Purpose |
| --- | --- |
| `senior-dotnet-engineer` | .NET conventions for this workspace |
| `senior-flutter-engineer` | Flutter conventions |
| `senior-frontend-engineer` | Frontend conventions |

## Sync AWS skills into this workspace

`aws configure agent-toolkit` installs to **`~/.cursor/skills`** globally. Copy into the repo workspace for Cursor to pick them up:

```bash
./scripts/sync-agent-toolkit-skills-to-repo.sh
```

Skills remain **untracked**; they are for your local editor only.

## AWS MCP server (project)

This repo ships [`.cursor/mcp.json`](../mcp.json) with the **`aws-mcp`** server:

- **Command:** `uvx mcp-proxy-for-aws@latest`
- **Endpoint:** `https://aws-mcp.us-east-1.api.aws/mcp`

**Prerequisites:** [uv](https://docs.astral.sh/uv/) on your `PATH` and valid AWS credentials (Lab 2 profile).

Refresh from global config after re-running Agent Toolkit:

```bash
./scripts/sync-agent-toolkit-mcp-to-repo.sh
```

Docs: [AWS MCP server in Agent Toolkit](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/getting-started-aws-mcp-server.html).
