# Dev container — AWS Open Lab

Linux environment with **CLIs preinstalled** for lab scripts, GitHub workflow, and upcoming IaC/serverless labs. Console steps still use your **browser**; credentials come from a **host mount**, not the image.

## CLI toolchain (in the image)

| Tool | Used for |
| --- | --- |
| **aws** (CLI v2) | All labs, budgets, STS |
| **gh** | PRs, issues, `/commit` flows ([`.cursor/README.md`](../.cursor/README.md)) |
| **jq** / **yq** | Budget scripts, YAML/JSON |
| **terraform** | Lab 6 (IaC) |
| **node** / **npm** / **cdk** | AWS CDK (Lab 6+) |
| **uv** / **uvx** | [AWS MCP](../.cursor/mcp.json) (`mcp-proxy-for-aws`) |
| **session-manager-plugin** | SSM sessions (compute/containers labs) |
| **kubectl** | EKS/containers (future) |
| **sam** | Serverless stretch / Lab 5–6 |
| **shellcheck** | Bash lab scripts |
| **git** / **make** / **python3** | Repo + small automation |

Verify after build:

```bash
bash .devcontainer/verify-tools.sh
```

## Credentials & auth

| Mount / action | Purpose |
| --- | --- |
| Host `~/.aws` → container | **lab-admin** profile (Lab 2) |
| `gh auth login` in container | GitHub (token stored in container or mount `~/.config/gh` yourself) |
| `labs/**/config/.env` | Lab vars (scaffolded from `*.env.example`, gitignored) |

Default env: **`AWS_PROFILE=lab-admin`**.

## Open / rebuild

1. **Dev Containers: Reopen in Container**
2. Wait for build + `post-create.sh`
3. Edit `config/.env` files as needed
4. Run `bash labs/02-aws-cli/scripts/verify-aws-cli-setup.sh`

Rebuild when **`Dockerfile`** changes.

## Design notes

- **Single Dockerfile** — predictable versions; no duplicate AWS CLI from Dev Features.
- **Multi-arch** — `amd64` and `arm64` for AWS CLI, SSM plugin, kubectl.
- **Not in image** — AWS access keys, `.env` secrets, Agent Toolkit skills (sync script), Docker-in-Docker (add later if a lab needs it).

## Files

| File | Role |
| --- | --- |
| `Dockerfile` | Installs CLI toolchain |
| `devcontainer.json` | Mounts, extensions, post-create |
| `verify-tools.sh` | Version smoke test |
| `post-create.sh` | Scaffold `.env`, verify tools, credential hints |
