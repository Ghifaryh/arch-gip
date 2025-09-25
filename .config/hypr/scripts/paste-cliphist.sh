#!/usr/bin/env bash
set -euo pipefail

PROMPT='Clipboard'

# Find rofi PIDs that are the specific dmenu with our prompt
find_rofi_pids() {
  local pids=()
  local pid cmd
  # pgrep may return nothing -> don't fail
  for pid in $(pgrep -x rofi || true); do
    # /proc/<pid>/cmdline is NUL-separated; make it spaces for matching
    cmd="$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null || true)"
    # Match: rofi ... -dmenu ... -p Clipboard ...
    case "$cmd" in
    *"-dmenu"*"-p"*"$PROMPT"*) pids+=("$pid") ;;
    esac
  done
  printf '%s\n' "${pids[@]:-}"
}

# Toggle: if it's already open, close it and exit.
if
  rofi_pids="$(find_rofi_pids)"
  [ -n "${rofi_pids:-}" ]
then
  # Try graceful close first
  while read -r pid; do
    kill -TERM "$pid" 2>/dev/null || true
  done <<<"$rofi_pids"
  # Give rofi a moment to exit; fall back to KILL if stubborn
  sleep 0.05
  if
    rofi_pids2="$(find_rofi_pids)"
    [ -n "${rofi_pids2:-}" ]
  then
    while read -r pid; do
      kill -KILL "$pid" 2>/dev/null || true
    done <<<"$rofi_pids2"
  fi
  exit 0
fi

# Not open → show the menu
choice="$(cliphist list | rofi -dmenu -p "$PROMPT" || true)"
[ -n "${choice:-}" ] || exit 0

# Decode & copy without trailing newline, then paste after a short beat
printf %s "$choice" | cliphist decode | wl-copy -n
sleep 0.08
exec wtype -M ctrl v -m ctrl
