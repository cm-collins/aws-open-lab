# DevOps engineer path — checklist

Use this with the [lab sequence](../labs/README.md). **Labs 1–2** are written; **3–6** are planned in the root README but not in the repo yet—treat the Lab 3–6 sections below as **targets** until those folders exist.

**Prerequisite:** [Labs 1–2 completion checklist](labs-1-2-checklist.md) (account guardrails, **`lab-admin`**, CLI **VERIFIED**, home **region** chosen).

---

## Phase 0 — Close gaps (if anything is unchecked)

- [ ] Lab 1 runbooks **1–5** done (MFA, budget, **`lab-admin`**, billing group if needed)
- [ ] `bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh` → **VERIFIED**
- [ ] Default region set: `aws configure get region --profile lab-admin`
- [ ] Optional: Lab 1 budget CLI runbooks (automation practice)
- [ ] Read [Foundations — IAM, VPC, EC2, S3](foundations.md) once

---

## Phase 1 — Core platform (repo Labs 3–6, in order)

These match what this repo intends to teach next. Do not skip order: each lab assumes the previous one.

### Lab 3 — Networking (next lab to build / explore)

**Goal:** One VPC, public + private subnets, routing, security groups—everything else hangs off this.

When runbooks land in `labs/03-networking/`, you should be able to check off:

- [ ] VPC with CIDR you can explain (e.g. `10.0.0.0/16`)
- [ ] At least two AZs; public subnets (IGW) and private subnets (no direct internet)
- [ ] Route tables: public → IGW; private → NAT (if runbook includes NAT) or no outbound yet
- [ ] Security groups: stateful rules; difference from NACLs
- [ ] **Verify:** reachability only where you intended (no “open to 0.0.0.0/0” surprises)
- [ ] **Teardown:** delete NAT/EIP first if used, then subnets, IGW, VPC

**DevOps depth (same lab or stretch):** VPC endpoints (S3, ECR) to avoid NAT cost; flow logs to CloudWatch.

### Lab 4 — Compute

- [ ] EC2 in a **private** or **public** subnet on purpose (not default VPC forever)
- [ ] SSH/session access via bastion or SSM Session Manager (prefer SSM for ops hygiene)
- [ ] Instance profile (IAM role on EC2)—no long-lived keys on the box
- [ ] Stop/terminate when done; understand billing while **running**

**DevOps depth:** User data for bootstrap; golden AMI vs config management; Auto Scaling group (min/desired/max).

### Lab 5 — Storage

- [ ] S3 bucket **private by default**; block public access on
- [ ] Encryption (SSE-S3 or SSE-KMS) and who can decrypt (KMS key policy)
- [ ] Lifecycle or versioning—when you would use each
- [ ] Access via IAM policy, not public URLs

**DevOps depth:** S3 for artifacts (CI), Terraform state bucket (versioning + lock table later).

### Lab 6 — Infrastructure as code

- [ ] Same stack as a prior lab recreated in **Terraform** or **CDK** (repo dev container has both)
- [ ] State remote or local—with understanding of team workflow (remote + lock)
- [ ] `plan` before `apply`; destroy when finished

**DevOps depth:** Modules/stacks; environments (dev/stage); policy-as-code (optional: OPA, CFN guard).

---

## Phase 2 — DevOps practice areas (after Phase 1)

Not yet first-class labs in this repo; use AWS docs + small spikes in the **same** account (with budget alerts on).

### Identity and access (ongoing)

- [ ] Replace “admin user + keys” mental model with **roles** and **least privilege**
- [ ] IAM Identity Center (SSO) for human access; roles for CI and EC2/Lambda
- [ ] Permission boundaries and separation of duties (who can change IAM vs deploy)

### CI/CD

- [ ] One pipeline: GitHub Actions or CodePipeline building and deploying to S3/EC2/ECS
- [ ] OIDC trust to AWS (no static `AKIA` in GitHub secrets)
- [ ] Deploy to a **non-prod** account or clearly tagged resources first

### Containers and orchestration

- [ ] ECR: push an image; pull from EC2 or Fargate
- [ ] ECS Fargate **or** EKS (pick one for depth—not both on day one)
- [ ] ALB + target group + health checks

### Observability

- [ ] CloudWatch metrics and alarms on one resource you care about
- [ ] Log groups, retention, and a simple dashboard
- [ ] X-Ray or ADOT only after logs/metrics feel boring

### Reliability and ops

- [ ] Multi-AZ for something that matters (RDS or ALB+ASG)
- [ ] Backup: AWS Backup or RDS snapshots; restore drill once
- [ ] Runbook: “service down” → metrics → logs → recent deploy

### Security and compliance (DevOps-facing)

- [ ] AWS Config or Security Hub trial—one finding you fix end-to-end
- [ ] Secrets Manager or SSM Parameter Store for app secrets (not `.env` on disk in prod)
- [ ] GuardDuty optional (cost-aware toggle)

---

## Phase 3 — “Job-ready” capstone (you design it)

Build **one** system that touches most of Phase 1–2:

Example: **VPC → private ECS Fargate → RDS → ALB → CI deploy via OIDC → alarms on 5xx/latency → Terraform repo.**

Checklist:

- [ ] Diagram (network + IAM trust lines)
- [ ] IaC repo; no manual console drift for core resources
- [ ] Cost estimate and teardown documented
- [ ] Post-incident note: one thing you would automate next

---

## How to use this repo while Labs 3–6 are missing

1. Work Phase 0 from [labs-1-2-checklist.md](labs-1-2-checklist.md).
2. **Next explore:** networking (Lab 3)—either contribute `labs/03-networking/` here using [runbook template](../labs/runbooks/TEMPLATE.md) or follow AWS’s VPC getting started in your home region and write runbooks as you go.
3. After each session: update **Last verified**, note region, PR improvements.

---

## Suggested weekly rhythm (depth over speed)

| Week focus | Emphasis |
| --- | --- |
| 1 | Phase 0 + foundations doc |
| 2–3 | VPC lab (draw diagrams, break routing on purpose) |
| 4 | EC2 + SSM + instance roles |
| 5 | S3 + IAM policies |
| 6 | Terraform/CDK port of VPC+EC2 |
| 7+ | One Phase 2 topic per week (CI, then containers, then observability) |

Adjust pace; tear down billable resources between weeks.
