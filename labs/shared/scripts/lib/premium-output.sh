#!/usr/bin/env bash
# Premium CLI summaries for aws-open-lab scripts (stdout). Logs/debug stay on stderr.

PO_WIDTH="${PO_WIDTH:-78}"
PO_LABEL_W="${PO_LABEL_W:-28}"
PO_STATUS_W="${PO_STATUS_W:-10}"

PO_USE_COLOR=0
if [[ -t 1 ]] && [[ "${NO_COLOR:-}" == "" ]]; then
  PO_USE_COLOR=1
fi

# ASCII borders by default (readable in all terminals). Set PO_UTF8_BOX=1 for ═/─.
if [[ "${PO_UTF8_BOX:-0}" == 1 ]]; then
  PO_CH_HEAVY='═'
  PO_CH_LIGHT='─'
else
  PO_CH_HEAVY='='
  PO_CH_LIGHT='-'
fi

_po_c() {
  local code="$1"
  shift
  if [[ "$PO_USE_COLOR" == 1 ]]; then
    printf '\033[%sm' "$code"
  fi
}

po_reset() { _po_c 0; }
po_dim() { _po_c "2"; }
po_green() { _po_c "32"; }
po_yellow() { _po_c "33"; }
po_red() { _po_c "31"; }
po_bold() { _po_c "1"; }

po_timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u
}

po_repeat_char() {
  local char="$1" count="$2"
  printf '%*s' "$count" '' | tr ' ' "$char"
}

po_banner() {
  local title="$1"
  local subtitle="${2:-}"
  local line
  line="$(po_repeat_char "$PO_CH_HEAVY" "$PO_WIDTH")"
  echo ""
  po_bold
  echo "$line"
  printf '  %s\n' "$title"
  po_reset
  if [[ -n "$subtitle" ]]; then
    po_dim
    printf '  %s\n' "$subtitle"
    po_reset
  fi
  po_bold
  echo "$line"
  po_reset
}

po_section() {
  local name="$1"
  echo ""
  po_bold
  printf '  %s\n' "$name"
  po_reset
  po_dim
  printf '  %s\n' "$(po_repeat_char "$PO_CH_LIGHT" $((PO_WIDTH - 2)))"
  po_reset
}

po_table_header() {
  po_bold
  printf '  %-'"${PO_LABEL_W}"'s %-'${PO_STATUS_W}'s %s\n' "CHECK" "STATUS" "DETAIL"
  po_reset
  po_dim
  printf '  %s\n' "$(po_repeat_char "$PO_CH_LIGHT" $((PO_WIDTH - 2)))"
  po_reset
}

_po_status_fmt() {
  local status="$1"
  local up="${status^^}"
  case "$up" in
    OK | CREATED | UPDATED | DELETED | VERIFIED | READY)
      po_green
      printf '%s' "$status"
      ;;
    SKIP | SKIPPED | NO-OP | WARN | WARNING)
      po_yellow
      printf '%s' "$status"
      ;;
    FAIL | FAILED | ERROR)
      po_red
      printf '%s' "$status"
      ;;
    *)
      printf '%s' "$status"
      ;;
  esac
  po_reset
}

po_row() {
  local label="$1"
  local status="$2"
  local detail="$3"
  printf '  %-'"${PO_LABEL_W}"'s ' "$label"
  _po_status_fmt "$status"
  printf ' %*s %s\n' "$((PO_STATUS_W - ${#status}))" "" "$detail"
}

po_key_value_block() {
  local key="$1"
  local value="$2"
  printf '  %-'"${PO_LABEL_W}"'s %s\n' "$key" "$value"
}

po_outcome() {
  local status="$1"
  local detail="${2:-}"
  echo ""
  po_section "Summary"
  printf '  %-'"${PO_LABEL_W}"'s ' "OUTCOME"
  _po_status_fmt "$status"
  echo ""
  if [[ -n "$detail" ]]; then
    po_key_value_block "Detail" "$detail"
  fi
  local line
  line="$(po_repeat_char "$PO_CH_HEAVY" "$PO_WIDTH")"
  echo ""
  po_dim
  echo "$line"
  po_reset
  echo ""
}

po_mask_email() {
  local email="$1"
  if [[ "$email" =~ ^([^@]+)@(.+)$ ]]; then
    local user="${BASH_REMATCH[1]}"
    local domain="${BASH_REMATCH[2]}"
    if ((${#user} <= 2)); then
      printf '%s@%s' "***" "$domain"
    else
      printf '%s***@%s' "${user:0:2}" "$domain"
    fi
  else
    printf '***'
  fi
}

po_mask_account() {
  local id="$1"
  if ((${#id} >= 8)); then
    printf '%s…%s' "${id:0:4}" "${id: -4}"
  else
    printf '%s' "$id"
  fi
}
