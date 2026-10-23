#!/usr/bin/env bash
# ============================================================================
#  Скриншот выделенной области: grim + slurp → файл + буфер + уведомление.
#  Mod+Shift+S
# ============================================================================
set -euo pipefail

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/Shot $(date '+%Y-%m-%d %H-%M-%S').png"

geometry=$(slurp 2>/dev/null) || exit 0

grim -g "$geometry" "$file"
wl-copy < "$file"
notify-send -a "Скриншот" -i camera-photo "Скриншот сохранён" "$(basename "$file")"
