#!/bin/bash

# omarchy:summary=Toggle sleep on lid close

PATTERN="systemd-inhibit --what=handle-lid-switch"

if pgrep -f "$PATTERN" >/dev/null 2>&1; then
  pkill -f "$PATTERN"
  if command -v omarchy-notification-send >/dev/null 2>&1; then
    omarchy-notification-send -g 󰌢 "Lid Sleep" "Inactive (lid close will sleep)"
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "Lid Sleep" "Inactive (lid close will sleep)" -i laptop
  fi
else
  nohup systemd-inhibit --what=handle-lid-switch --who="Lid Sleep" --why="Prevent sleep on lid close" sleep infinity >/dev/null 2>&1 &
  if command -v omarchy-notification-send >/dev/null 2>&1; then
    omarchy-notification-send -g 󰌢 "Lid Sleep" "Active (lid close won't sleep)"
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "Lid Sleep" "Active (lid close won't sleep)" -i laptop
  fi
fi
