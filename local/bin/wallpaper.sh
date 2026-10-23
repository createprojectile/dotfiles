#!/usr/bin/env bash
# ============================================================================
#  Обои на каждый монитор.
#  Запускается из niri (autostart.kdl) и вручную: wallpaper.sh
# ============================================================================
set -euo pipefail

WALL_DIR="${WALLPAPER_DIR:-$HOME/.local/share/wallpapers}"
PRIMARY="$WALL_DIR/ayu-dark.png"
SECONDARY="$WALL_DIR/ayu-dark-alt.png"

[[ -f "$PRIMARY" ]] || { echo "Нет обоев: $PRIMARY" >&2; exit 1; }

pkill -x swaybg 2>/dev/null || true

args=(-o DP-1 -i "$PRIMARY" -m fill)
if [[ -f "$SECONDARY" ]]; then
    args+=(-o HDMI-A-1 -i "$SECONDARY" -m fill)
fi

exec swaybg "${args[@]}"
