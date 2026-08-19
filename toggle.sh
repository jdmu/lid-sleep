#!/bin/bash

# omarchy:summary=Toggle whether lid close triggers sleep

PATTERN="systemd-inhibit --what=handle-lid-switch"

if pgrep -f "$PATTERN" >/dev/null 2>&1; then
  pkill -f "$PATTERN"
  if command -v omarchy-notification-send >/dev/null 2>&1; then
    omarchy-notification-send -g 󰌢 "Lid Sleep Enabled" "System will sleep when lid is closed"
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "Lid Sleep Enabled" "System will sleep when lid is closed" -i laptop
  fi
else
  nohup systemd-inhibit --what=handle-lid-switch --who="Lid Sleep" --why="Prevent sleep on lid close" sleep infinity >/dev/null 2>&1 &
  if command -v omarchy-notification-send >/dev/null 2>&1; then
    omarchy-notification-send -g 󰌢 "Lid Sleep Prevented" "System will stay awake when lid is closed"
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "Lid Sleep Prevented" "System will stay awake when lid is closed" -i laptop
  fi
fi
