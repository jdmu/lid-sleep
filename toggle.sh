#!/bin/bash

# omarchy:summary=Toggle whether lid close triggers sleep

ACTION="${1:-toggle}"

if command -v omarchy-shell >/dev/null 2>&1; then
  exec omarchy-shell lid-sleep "$ACTION"
else
  echo "omarchy-shell not found" >&2
  exit 1
fi
