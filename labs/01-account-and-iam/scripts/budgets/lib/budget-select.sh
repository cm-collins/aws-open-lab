#!/usr/bin/env bash
# Interactive numbered budget selection (TTY). Source from delete/update scripts.

# Fills BUDGET_NAMES[] and BUDGET_LIST_JSON. Returns 0 if JSON fetched.
budget_load_all_budgets() {
  local account_id="$1"
  lab_set_phase "List all budgets (DescribeBudgets)"
  if ! BUDGET_LIST_JSON="$(aws "${AWS_PROFILE_ARGS[@]}" budgets describe-budgets \
    --account-id "$account_id" \
    --output json 2>&1)"; then
    LAB_AWS_LAST_ERROR="$BUDGET_LIST_JSON"
    lab_log_error "DescribeBudgets failed: $(lab_aws_first_line)"
    return 1
  fi
  BUDGET_NAMES=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && BUDGET_NAMES+=("$line")
  done < <(jq -r '.Budgets[].BudgetName' <<<"$BUDGET_LIST_JSON")
  return 0
}

budget_print_selection_table() {
  local hint_name="${1:-}"
  local i name limit spend
  po_section "Available budgets"
  po_bold
  printf '  %-4s %-32s %s\n' "#" "BUDGET NAME" "LIMIT · SPEND (USD)"
  po_reset
  po_dim
  printf '  %s\n' "$(po_repeat_char "${PO_CH_LIGHT:--}" $((PO_WIDTH - 2)))"
  po_reset
  for i in "${!BUDGET_NAMES[@]}"; do
    name="${BUDGET_NAMES[$i]}"
    limit="$(jq -r --arg n "$name" '.Budgets[] | select(.BudgetName == $n) | .BudgetLimit.Amount' <<<"$BUDGET_LIST_JSON")"
    spend="$(jq -r --arg n "$name" '.Budgets[] | select(.BudgetName == $n) | .CalculatedSpend.Amount // "0"' <<<"$BUDGET_LIST_JSON")"
    if [[ -n "$hint_name" && "$name" == "$hint_name" ]]; then
      printf '  %-4s %-32s %s · %s (from .env)\n' "$((i + 1))" "$name" "$limit" "$spend"
    else
      printf '  %-4s %-32s %s · %s\n' "$((i + 1))" "$name" "$limit" "$spend"
    fi
  done
  echo ""
}

# verb: short label for prompts (e.g. delete, update)
budget_prompt_select_index() {
  local hint="${1:-}"
  local verb="${2:-select}"
  local count="${#BUDGET_NAMES[@]}"
  local choice
  local tty_in="/dev/tty"

  budget_print_selection_table "$hint"

  if [[ ! -e "$tty_in" ]] || [[ ! -r "$tty_in" ]]; then
    lab_log_error "Interactive selection requires a TTY (see runbook — use --name in CI)."
    return 2
  fi

  po_dim
  printf '  Enter number to %s (1-%s), or q to cancel: ' "$verb" "$count" >/dev/tty
  po_reset
  if ! IFS= read -r choice <"$tty_in"; then
    lab_log_error "Could not read selection."
    return 2
  fi

  choice="${choice//[[:space:]]/}"
  case "$choice" in
    q | Q)
      lab_log_info "Selection cancelled by user."
      return 3
      ;;
  esac

  if [[ ! "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > count)); then
    lab_log_error "Invalid choice: ${choice} (expected 1-${count})"
    return 2
  fi

  BUDGET_SELECTED_NAME="${BUDGET_NAMES[$((choice - 1))]}"
  lab_log_info "Selected: ${BUDGET_SELECTED_NAME}"
  return 0
}

# Sets BUDGET_SELECTED_NAME. verb is delete|update for prompts.
# Args after account_id and verb: [--name X] [--interactive] [-h]
budget_resolve_interactive_target() {
  local account_id="$1"
  local verb="$2"
  shift 2
  local flag_name=""
  local force_interactive=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name)
        flag_name="${2:?--name requires a value}"
        shift 2
        ;;
      --interactive | -i)
        force_interactive=1
        shift
        ;;
      -h | --help)
        return 10
        ;;
      *)
        lab_log_error "Unknown argument: $1"
        return 2
        ;;
    esac
  done

  if ! budget_load_all_budgets "$account_id"; then
    return 1
  fi

  local count="${#BUDGET_NAMES[@]}"
  if ((count == 0)); then
    BUDGET_SELECTED_NAME=""
    return 0
  fi

  if [[ -n "$flag_name" ]]; then
    BUDGET_SELECTED_NAME="$flag_name"
    return 0
  fi

  local use_interactive=0
  if [[ "$force_interactive" == 1 ]]; then
    use_interactive=1
  elif [[ -t 0 ]] && [[ -t 1 ]]; then
    use_interactive=1
  fi

  if [[ "$use_interactive" == 1 ]]; then
    if ((count == 1)); then
      budget_print_selection_table "${BUDGET_NAME:-}"
      po_dim
      printf '  One budget found. Press Enter to %s it, or q to cancel: ' "$verb" >/dev/tty
      po_reset
      local confirm
      IFS= read -r confirm <"/dev/tty" || true
      case "${confirm//[[:space:]]/}" in
        q | Q)
          return 3
          ;;
      esac
      BUDGET_SELECTED_NAME="${BUDGET_NAMES[0]}"
      return 0
    fi
    budget_prompt_select_index "${BUDGET_NAME:-}" "$verb"
    return $?
  fi

  if [[ -n "${BUDGET_NAME:-}" ]]; then
    BUDGET_SELECTED_NAME="$BUDGET_NAME"
    return 0
  fi

  lab_log_error "Non-interactive mode: set BUDGET_NAME in .env or pass --name"
  return 2
}

budget_resolve_delete_target() {
  budget_resolve_interactive_target "$1" delete "${@:2}"
}

budget_resolve_update_target() {
  budget_resolve_interactive_target "$1" update "${@:2}"
}

# Validates a USD budget amount string. Returns 0 if OK.
budget_validate_usd_amount() {
  local amount="$1"
  [[ -n "$amount" ]] || return 1
  [[ "$amount" =~ ^[0-9]+(\.[0-9]{1,2})?$ ]] || return 1
  awk -v a="$amount" 'BEGIN { if (a + 0 <= 0) exit 1; exit 0 }'
}

# Sets BUDGET_LIMIT_USD from /dev/tty. Args: current_aws_limit [hint_from_env]
budget_prompt_monthly_limit() {
  local current="${1:-}"
  local env_hint="${2:-}"
  local tty_in="/dev/tty"
  local input

  lab_set_phase "Prompt for new monthly limit"

  if [[ ! -e "$tty_in" ]] || [[ ! -r "$tty_in" ]]; then
    lab_log_error "Interactive limit entry requires a TTY."
    return 2
  fi

  po_section "New limit"
  po_table_header
  if [[ -n "$current" && "$current" != "—" ]]; then
    po_row "Current (AWS)" "OK" "USD ${current}"
  fi
  if [[ -n "$env_hint" ]]; then
    po_row ".env BUDGET_LIMIT_USD" "OK" "USD ${env_hint} (not used unless you type it)"
  fi
  echo ""
  po_dim
  if [[ -n "$current" ]]; then
    printf '  Type new monthly limit in USD (current %s), or q to cancel: ' "$current" >/dev/tty
  else
    printf '  Type new monthly limit in USD, or q to cancel: ' >/dev/tty
  fi
  po_reset

  if ! IFS= read -r input <"$tty_in"; then
    lab_log_error "Could not read input."
    return 2
  fi

  input="${input//[[:space:]]/}"
  case "$input" in
    q | Q)
      lab_log_info "Update cancelled by user."
      return 3
      ;;
  esac

  if ! budget_validate_usd_amount "$input"; then
    lab_log_error "Invalid amount: ${input} (use a positive number, e.g. 10 or 25.50)"
    return 2
  fi

  BUDGET_LIMIT_USD="$input"
  lab_log_info "New limit entered: USD ${BUDGET_LIMIT_USD}"
  return 0
}

# After update: optionally write limit into config/.env (BUDGET_LIMIT_USD + BUDGET_LIMIT_USD_CLI).
budget_offer_sync_limit_to_env() {
  local new_limit="$1"
  local budget_name="$2"
  local tty_in="/dev/tty"
  local answer

  [[ -f "$LAB_CONFIG_FILE" ]] || return 0
  # Prompt only on a real interactive terminal (/dev/tty may exist but not be usable in CI/agents).
  if [[ ! -t 0 ]] || [[ ! -t 1 ]] || [[ ! -e "$tty_in" ]] || [[ ! -r "$tty_in" ]] || [[ ! -w "$tty_in" ]]; then
    return 0
  fi

  po_section "Sync .env"
  po_table_header
  po_row "Suggested" "OK" "BUDGET_LIMIT_USD_CLI=${new_limit}"
  echo ""
  po_dim
  printf '  Update %s with new limit %s? [Y/n]: ' "$LAB_CONFIG_FILE" "$new_limit" >/dev/tty
  po_reset
  IFS= read -r answer <"$tty_in" || return 0
  case "${answer:-Y}" in
    n | N)
      lab_log_info "Skipped .env sync"
      po_row ".env sync" "SKIP" "unchanged"
      return 0
      ;;
  esac

  lab_set_phase "Update config/.env limits"
  local tmp
  tmp="$(mktemp)"
  awk -v lim="$new_limit" -v bname="$budget_name" '
    BEGIN { dg=0; dc=0; dnc=0 }
    /^BUDGET_LIMIT_USD=/ { print "BUDGET_LIMIT_USD=" lim; dg=1; next }
    /^BUDGET_LIMIT_USD_CLI=/ { print "BUDGET_LIMIT_USD_CLI=" lim; dc=1; next }
    /^BUDGET_NAME_CLI=/ { print "BUDGET_NAME_CLI=" bname; dnc=1; next }
    { print }
    END {
      if (!dg) print "BUDGET_LIMIT_USD=" lim
      if (!dc) print "BUDGET_LIMIT_USD_CLI=" lim
      if (!dnc && bname ~ /cli/) print "BUDGET_NAME_CLI=" bname
    }
  ' "$LAB_CONFIG_FILE" >"$tmp"
  mv "$tmp" "$LAB_CONFIG_FILE"
  lab_log_info "Updated ${LAB_CONFIG_FILE}"
  po_row ".env sync" "OK" "limits saved for verify"
}
