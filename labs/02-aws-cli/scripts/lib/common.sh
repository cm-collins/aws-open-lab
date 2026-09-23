#!/usr/bin/env bash
# Shared helpers for Lab 2 CLI scripts.

set -euo pipefail

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../shared/scripts/lib/premium-output.sh
source "${_LIB_DIR}/../../../shared/scripts/lib/premium-output.sh"
# shellcheck source=../../../shared/scripts/lib/lab-runtime.sh
source "${_LIB_DIR}/../../../shared/scripts/lib/lab-runtime.sh"

_LAB_CONFIG_DIR="$(cd "${_LIB_DIR}/../../config" && pwd)"
lab_runtime_init \
  "${_LAB_CONFIG_DIR}/.env" \
  "${_LAB_CONFIG_DIR}/cli.env.example" \
  "optional"

log() {
  lab_log_info "$*"
}
