#!/usr/bin/env bash
# Print versions of CLIs baked into the dev container (run after build or post-create).

set -euo pipefail

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf '  OK  %-22s %s\n' "$label" "$("$@" 2>&1 | head -1)"
  else
    printf '  FAIL %-22s (not on PATH)\n' "$label"
    return 1
  fi
}

FAIL=0
echo ""
echo "=== Dev container CLI toolchain ==="
check "aws" aws --version || FAIL=1
check "gh" gh --version || FAIL=1
check "jq" jq --version || FAIL=1
check "yq" yq --version || FAIL=1
check "terraform" terraform version || FAIL=1
check "node" node --version || FAIL=1
check "npm" npm --version || FAIL=1
check "cdk" cdk --version || FAIL=1
check "uv" uv --version || FAIL=1
check "uvx" uvx --version || FAIL=1
check "session-manager-plugin" session-manager-plugin --version || FAIL=1
check "kubectl" kubectl version --client=true || FAIL=1
check "sam" sam --version || FAIL=1
check "shellcheck" shellcheck --version || FAIL=1
check "git" git --version || FAIL=1
check "python3" python3 --version || FAIL=1
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "All core tools present."
else
  echo "One or more tools missing — rebuild the dev container."
  exit 1
fi
