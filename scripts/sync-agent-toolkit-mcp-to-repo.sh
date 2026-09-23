#!/usr/bin/env bash
# Copy the aws-mcp server block from ~/.cursor/mcp.json into this repo's .cursor/mcp.json.
# Run after: aws configure agent-toolkit

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${HOME}/.cursor/mcp.json"
DEST="${REPO_ROOT}/.cursor/mcp.json"

if [[ ! -f "$SRC" ]]; then
  echo "Source not found: $SRC — run: aws configure agent-toolkit" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

AWS_MCP="$(jq '.mcpServers["aws-mcp"]' "$SRC")"
if [[ "$AWS_MCP" == "null" ]]; then
  echo 'No mcpServers["aws-mcp"] in ~/.cursor/mcp.json' >&2
  exit 1
fi

jq -n --argjson aws_mcp "$AWS_MCP" '{ mcpServers: { "aws-mcp": $aws_mcp } }' >"$DEST"
echo "Wrote ${DEST}"
