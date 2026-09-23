#!/usr/bin/env bash
# Lab 2: verify AWS CLI v2, profile, and caller identity.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

lab_log_info "Starting verify-aws-cli-setup.sh"

export AWS_PROFILE="${AWS_PROFILE:-lab-admin}"

OVERALL="VERIFIED"
DETAIL="Ready for Lab 1 budget scripts and later labs."

po_banner "AWS Open Lab — Verify CLI Setup" \
  "Lab 2 · $(po_timestamp_utc) · profile ${AWS_PROFILE}"

po_section "Environment"
po_table_header
if [[ "$LAB_ENV_LOADED" == 1 ]]; then
  po_row "Config file" "OK" "${LAB_CONFIG_FILE}"
else
  po_row "Config file" "WARN" "optional (using AWS_PROFILE=${AWS_PROFILE})"
fi

po_section "Preflight checks"
po_table_header

lab_set_phase "Check AWS CLI on PATH"
if command -v aws >/dev/null 2>&1; then
  version_line="$(aws --version 2>&1)"
  po_row "AWS CLI installed" "OK" "${version_line}"
  lab_log_info "Detected: ${version_line}"
else
  po_row "AWS CLI installed" "FAIL" "aws not on PATH"
  po_outcome "FAILED" "Complete Lab 2 install runbook."
  exit 1
fi

case "$version_line" in
  aws-cli/2.*) po_row "CLI major version" "OK" "v2" ;;
  *)
    po_row "CLI major version" "FAIL" "Need aws-cli/2.x"
    po_outcome "FAILED" "Upgrade AWS CLI v2."
    exit 1
    ;;
esac

lab_set_phase "Read profile region"
region="$(aws configure get region --profile "$AWS_PROFILE" 2>/dev/null || true)"
if [[ -n "$region" ]]; then
  po_row "Default region" "OK" "${region}"
else
  po_row "Default region" "FAIL" "unset for profile"
  po_outcome "FAILED" "Run: aws configure --profile ${AWS_PROFILE}"
  exit 1
fi

lab_set_phase "Verify STS GetCallerIdentity"
sts_err=""
if arn="$(aws sts get-caller-identity --query Arn --output text 2>&1)"; then
  account="$(aws sts get-caller-identity --query Account --output text)"
  po_row "STS GetCallerIdentity" "OK" "$(po_mask_account "$account")"
  po_row "Caller ARN" "OK" "${arn##*:user/}"
  lab_log_info "STS OK for ${arn}"
else
  sts_err="$arn"
  lab_log_error "STS failed: ${sts_err}"
  po_row "STS GetCallerIdentity" "FAIL" "${sts_err%%$'\n'*}"
  po_outcome "FAILED" "Fix credentials for profile ${AWS_PROFILE}."
  exit 1
fi

if [[ "$arn" == *':user/lab-admin' ]]; then
  po_row "Expected IAM user" "OK" "lab-admin"
else
  po_row "Expected IAM user" "WARN" "not lab-admin"
  DETAIL="CLI works; this lab expects IAM user lab-admin."
fi

po_outcome "$OVERALL" "$DETAIL"
exit 0
