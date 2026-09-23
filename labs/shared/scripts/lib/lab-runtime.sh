#!/usr/bin/env bash
# Runtime helpers: auto-load lab config/.env, phased stderr logging, ERR trap, AWS wrappers.

LAB_CURRENT_PHASE="startup"
LAB_CONFIG_FILE=""
LAB_ENV_EXAMPLE_FILE=""
LAB_ENV_LOADED=0
LAB_AWS_LAST_ERROR=""
LAB_SCRIPT_NAME="${LAB_SCRIPT_NAME:-${0##*/}}"

lab_log() {
  local level="$1"
  shift
  printf '[%s] [%s] %s: %s\n' "$(date -u +"%H:%M:%SZ" 2>/dev/null || date -u)" "$LAB_SCRIPT_NAME" "$level" "$*" >&2
}

lab_log_info() { lab_log "INFO" "$*"; }
lab_log_warn() { lab_log "WARN" "$*"; }
lab_log_error() { lab_log "ERROR" "$*"; }

lab_set_phase() {
  LAB_CURRENT_PHASE="$1"
  lab_log_info "→ ${LAB_CURRENT_PHASE}"
}

lab_on_err() {
  local exit_code="$1"
  local line_no="$2"
  lab_log_error "Stopped at line ${line_no} during: ${LAB_CURRENT_PHASE}"
  lab_log_error "Exit code ${exit_code}. Review ERROR/INFO lines above."
  if [[ "${LAB_DEBUG:-}" != "1" ]]; then
    lab_log_info "Tip: re-run with LAB_DEBUG=1 for shell trace (set -x)."
  fi
}

lab_runtime_init() {
  local config_file="$1"
  local example_file="$2"
  local mode="${3:-required}"

  LAB_CONFIG_FILE="$config_file"
  LAB_ENV_EXAMPLE_FILE="$example_file"

  if [[ "${LAB_DEBUG:-}" == "1" ]]; then
    set -x
  fi

  trap 'lab_on_err $? $LINENO' ERR

  lab_log_info "Bootstrapping ${LAB_SCRIPT_NAME}"

  lab_set_phase "Load lab configuration"
  if [[ -f "$LAB_CONFIG_FILE" ]]; then
    lab_log_info "Sourcing ${LAB_CONFIG_FILE}"
    set -a
    # shellcheck disable=SC1090
    source "$LAB_CONFIG_FILE"
    set +a
    LAB_ENV_LOADED=1
    lab_log_info "Configuration loaded"
  elif [[ "$mode" == "required" ]]; then
    lab_log_error "Missing config: ${LAB_CONFIG_FILE}"
    if [[ -f "$LAB_ENV_EXAMPLE_FILE" ]]; then
      lab_log_error "Create it: cp $(basename "$LAB_ENV_EXAMPLE_FILE") .env  (in $(dirname "$LAB_CONFIG_FILE"))"
      lab_log_error "Or: cp \"${LAB_ENV_EXAMPLE_FILE}\" \"${LAB_CONFIG_FILE}\""
      lab_log_error "Edit values in .env (never commit .env), then re-run this script."
    else
      lab_log_error "Create ${LAB_CONFIG_FILE} with the variables this script needs."
    fi
    exit 2
  else
    lab_log_warn "No ${LAB_CONFIG_FILE}; using shell defaults"
    export AWS_PROFILE="${AWS_PROFILE:-lab-admin}"
    lab_log_info "AWS_PROFILE=${AWS_PROFILE}"
  fi
}

lab_require_env() {
  lab_set_phase "Validate configuration variables"
  local name
  local missing=()
  for name in "$@"; do
    if [[ -z "${!name:-}" ]]; then
      missing+=("$name")
    fi
  done
  if ((${#missing[@]} > 0)); then
    lab_log_error "Missing required variable(s): ${missing[*]}"
    lab_log_error "Set them in: ${LAB_CONFIG_FILE}"
    if [[ -f "$LAB_ENV_EXAMPLE_FILE" ]]; then
      lab_log_error "See example: ${LAB_ENV_EXAMPLE_FILE}"
    fi
    exit 1
  fi
  lab_log_info "Required variables OK ($# checked)"
}

lab_require_commands() {
  lab_set_phase "Check local tools"
  local cmd
  local missing=()
  for cmd in "$@"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      lab_log_info "Found: ${cmd}"
    else
      missing+=("$cmd")
      lab_log_error "Not found: ${cmd}"
    fi
  done
  if ((${#missing[@]} > 0)); then
    lab_log_error "Install missing tool(s): ${missing[*]}"
    exit 1
  fi
}

lab_run_redact_cmd_log() {
  local msg="$*"
  msg="$(printf '%s' "$msg" | sed -E 's/--arg email [^ ]+/--arg email ***@***/g')"
  msg="$(printf '%s' "$msg" | sed -E 's/--account-id [0-9]{12}/--account-id ************/g')"
  msg="$(printf '%s' "$msg" | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-320)"
  printf '%s' "$msg"
}

# Run a command; log phase; capture stderr on failure. Usage: lab_run "label" cmd args...
lab_run() {
  local label="$1"
  shift
  lab_set_phase "$label"
  lab_log_info "Executing: $(lab_run_redact_cmd_log "$@")"
  local err_file
  err_file="$(mktemp)"
  if "$@" 2>"$err_file"; then
    rm -f "$err_file"
    lab_log_info "${label}: OK"
    return 0
  fi
  LAB_AWS_LAST_ERROR="$(tr '\n' ' ' <"$err_file" | sed 's/  */ /g' | cut -c1-240)"
  rm -f "$err_file"
  lab_log_error "${label}: failed — ${LAB_AWS_LAST_ERROR}"
  return 1
}

lab_aws_first_line() {
  local msg="${LAB_AWS_LAST_ERROR:-unknown error}"
  printf '%s' "${msg%%$'\n'*}"
}
