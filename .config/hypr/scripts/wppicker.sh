#!/usr/bin/env bash
set -Eeuo pipefail

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/Wallpaper"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

cd "$WALLPAPER_DIR" || exit 1
IFS=$'\n' # handle spaces in filenames

# === ROFI PICKER (icon preview, newest first) ===
# Use absolute paths as icons so rofi can always find them
SELECTED_WALL=$(
  for a in $(ls -t *.jpg *.jpeg *.png *.gif *.webp 2>/dev/null); do
    printf '%s\0icon\x1f%s\n' "$a" "$WALLPAPER_DIR/$a"
  done | rofi -dmenu -p "Wallpaper"
)
[ -z "${SELECTED_WALL:-}" ] && exit 0
SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# === OPTIONAL: generate colors with matugen (doesn't set wallpaper)
if command -v matugen >/dev/null 2>&1; then
  matugen image "$SELECTED_PATH" || true
fi

# === UPDATE SYMLINK (handy for other tools/config)
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

# === APPLY WALLPAPER via swww (newer CLI)
if ! pgrep -x swww-daemon >/dev/null 2>&1; then
  swww-daemon &
  sleep 0.5
fi

# Transition example: uncomment to get a subtle fade/crossfade
# swww img "$SYMLINK_PATH" --transition-type any --transition-duration 0.7
swww img "$SYMLINK_PATH"

#notify-send "Wallpaper changed" "$SELECTED_WALL"
