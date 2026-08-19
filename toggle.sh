#!/bin/bash

# omarchy:summary=Toggle whether lid close triggers sleep

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/plugins/lid-sleep"
PID_FILE="$STATE_DIR/inhibitor.pid"

is_inhibiting() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(<"$PID_FILE")
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      if grep -q "systemd-inhibit" "/proc/$pid/cmdline" 2>/dev/null; then
        return 0
      fi
    fi
  fi
  return 1
}

stop_inhibition() {
  local notify="${1:-true}"
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(<"$PID_FILE")
    rm -f "$PID_FILE"
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
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
  systemd-inhibit --what=handle-lid-switch --who="Lid Sleep" --why="Prevent sleep on lid close" sleep infinity >/dev/null 2>&1 &
  local pid=$!
  echo "$pid" > "$PID_FILE"

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
