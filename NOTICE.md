# Third-party notices

## AWS Agent Toolkit skills (not vendored in git)

Cursor skill directories from the [AWS Agent Toolkit](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/getting-started.html) default set are **not** committed to this repository. They are third-party material; install or sync them locally:

```bash
aws configure agent-toolkit   # global install to ~/.cursor/skills
./scripts/sync-agent-toolkit-skills-to-repo.sh
```

Follow AWS documentation and any license terms that apply to the Agent Toolkit on your machine. This repo’s [MIT License](LICENSE) applies to **aws-open-lab** original content (labs, runbooks, scripts under `labs/`, docs, and repo-specific `.cursor/skills/senior-*` skills).

## AWS MCP proxy

[`.cursor/mcp.json`](.cursor/mcp.json) references **`mcp-proxy-for-aws`** via `uvx`. That package is fetched at runtime; see [AWS MCP server in Agent Toolkit](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/getting-started-aws-mcp-server.html).
