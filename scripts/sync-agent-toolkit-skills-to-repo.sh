#!/usr/bin/env bash
# Copy AWS Agent Toolkit skills from ~/.cursor/skills into .cursor/skills/ (local workspace).
# These directories are gitignored — see NOTICE.md. Run after: aws configure agent-toolkit

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${HOME}/.cursor/skills"
DEST="${REPO_ROOT}/.cursor/skills"

SKILLS=(
  amazon-bedrock
  aws-ai-ml
  aws-auth
  aws-billing-and-cost-management
  aws-blocks
  aws-cdk
  aws-cloudformation
  aws-compute
  aws-containers
  aws-database
  aws-deployment
  aws-iam
  aws-messaging-and-streaming
  aws-networking
  aws-observability
  aws-sdk-js-v3-usage
  aws-sdk-python-usage
  aws-sdk-swift-usage
  aws-security
  aws-serverless
  aws-storage
  launch-with-aws
  setting-up-cloudwatch-observability
  signing-in-to-aws
)

if [[ ! -d "$SRC" ]]; then
  echo "Source not found: $SRC — run: aws configure agent-toolkit" >&2
  exit 1
fi

for name in "${SKILLS[@]}"; do
  if [[ ! -d "${SRC}/${name}" ]]; then
    echo "Missing global skill: ${name}" >&2
    exit 1
  fi
  rm -rf "${DEST}/${name}"
  cp -a "${SRC}/${name}" "${DEST}/${name}"
  echo "Synced ${name}"
done

echo "Done. ${#SKILLS[@]} skills in ${DEST}"
