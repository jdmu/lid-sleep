#!/bin/bash

# omarchy:summary=Toggle whether lid close triggers sleep

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/plugins/lid-sleep"
STATE_FILE="$STATE_DIR/inhibitor.state"
WHO_IDENTIFIER="org.omarchy.plugins.lid-sleep"

# Read PID and START_TIME from state file
read_state() {
  if [[ -f "$STATE_FILE" ]]; then
    local pid="" start_time=""
    read -r pid start_time < "$STATE_FILE" || true
    if [[ -n "$pid" ]]; then
      echo "$pid $start_time"
      return 0
    fi
  fi
  return 1
}

# Strictly validate that the process belongs to this plugin
is_our_inhibitor() {
  local pid="${1:-}"
  local expected_start="${2:-}"

  # Must be a valid numeric PID
  [[ -n "$pid" && "$pid" =~ ^[0-9]+$ ]] || return 1

  # Process directory must exist in /proc
  [[ -d "/proc/$pid" ]] || return 1

  # Must be owned by current user
  local owner
  owner=$(stat -c '%u' "/proc/$pid" 2>/dev/null || true)
  [[ "$owner" == "$UID" ]] || return 1

  # If start time was recorded, verify it hasn't changed (prevents recycled PID collision)
  if [[ -n "$expected_start" ]]; then
    local current_start
    current_start=$(awk '{print $22}' "/proc/$pid/stat" 2>/dev/null || true)
    [[ "$current_start" == "$expected_start" ]] || return 1
  fi

  # Verify exact command line identity
  local cmdline
  cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)
  if [[ "$cmdline" == *"systemd-inhibit"* && "$cmdline" == *"handle-lid-switch"* && "$cmdline" == *"$WHO_IDENTIFIER"* ]]; then
    return 0
  fi

  return 1
}

is_inhibiting() {
  local state
  if state=$(read_state); then
    local pid="${state%% *}"
    local start_time="${state#* }"
    if is_our_inhibitor "$pid" "$start_time"; then
      return 0
    fi
    # If stale or mismatched, clean up state file
    rm -f "$STATE_FILE"
  fi
  return 1
}

stop_inhibition() {
  local notify="${1:-true}"
  local state

  if state=$(read_state); then
    local pid="${state%% *}"
    local start_time="${state#* }"
    rm -f "$STATE_FILE"

    # Strictly revalidate process identity before sending any signal
    if is_our_inhibitor "$pid" "$start_time"; then
      kill "$pid" 2>/dev/null || true
    fi
  fi

  if [[ "$notify" == "true" ]]; then
    if command -v omarchy-notification-send >/dev/null 2>&1; then
      omarchy-notification-send -g "$(printf '\U000f0322')" "Lid Sleep Enabled" "System will sleep when lid is closed"
    elif command -v notify-send >/dev/null 2>&1; then
      notify-send "Lid Sleep Enabled" "System will sleep when lid is closed" -i laptop
    fi
  fi
}

start_inhibition() {
  mkdir -p "$STATE_DIR"
  systemd-inhibit --what=handle-lid-switch --who="$WHO_IDENTIFIER" --why="Prevent sleep on lid close" sleep infinity >/dev/null 2>&1 &
  local pid=$!
  local start_time
  start_time=$(awk '{print $22}' "/proc/$pid/stat" 2>/dev/null || true)

  echo "$pid $start_time" > "$STATE_FILE"

  if command -v omarchy-notification-send >/dev/null 2>&1; then
    omarchy-notification-send -g "$(printf '\U000f0322')" "Lid Sleep Prevented" "System will stay awake when lid is closed"
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "Lid Sleep Prevented" "System will stay awake when lid is closed" -i laptop
  fi
}

case "${1:-toggle}" in
  status)
    if is_inhibiting; then
      exit 0
    else
      exit 1
    fi
    ;;
  start)
    if ! is_inhibiting; then
      start_inhibition
    fi
    ;;
  stop)
    stop_inhibition "${2:-true}"
    ;;
  toggle)
    if is_inhibiting; then
      stop_inhibition true
    else
      start_inhibition
    fi
    ;;
  *)
    echo "Usage: $0 {status|start|stop|toggle}" >&2
    exit 2
    ;;
esac
