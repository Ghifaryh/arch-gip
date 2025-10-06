#!/usr/bin/env bash
set -euo pipefail

# ---- timings (seconds) ----
NOTICE_AFTER=15  # when to show "Timeout"
SUSPEND_AFTER=45 # when to sleep (from the moment you lock)

# ---- helpers ----
notify_timeout() {
  # Hyprland's built-in overlay notification
  # format: hyprctl notify <severity> <time_ms> "<message>"
  # severity: 0..2 (just use 0)
  command -v hyprctl >/dev/null 2>&1 &&
    hyprctl notify 0 3000 "Timeout" || true
}

suspend_now() {
  if command -v systemctl >/dev/null 2>&1; then
    systemctl suspend
  fi
}

# Run hyprlock in background and capture PID
hyprlock &
LOCK_PID=$!

# timer: show "Timeout" after NOTICE_AFTER
(
  sleep "$NOTICE_AFTER"
  # still locked?
  if kill -0 "$LOCK_PID" >/dev/null 2>&1; then
    notify_timeout
  fi
) &
NOTICE_TIMER=$!

# timer: suspend after SUSPEND_AFTER
(
  sleep "$SUSPEND_AFTER"
  if kill -0 "$LOCK_PID" >/dev/null 2>&1; then
    suspend_now
  fi
) &
SUSPEND_TIMER=$!

# Wait until you unlock (hyprlock exits)
wait "$LOCK_PID" || true

# Clean up timers if still running
kill "$NOTICE_TIMER" "$SUSPEND_TIMER" >/dev/null 2>&1 || true
exit 0
