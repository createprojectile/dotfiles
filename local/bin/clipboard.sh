#!/usr/bin/env bash
# ============================================================================
#  История буфера обмена через cliphist + fuzzel.
#  Mod+V
# ============================================================================
set -euo pipefail

command -v cliphist >/dev/null || { notify-send "Буфер обмена" "cliphist не установлен"; exit 1; }
command -v fuzzel  >/dev/null || exit 1

entry=$(cliphist list | fuzzel --dmenu --prompt "  " --lines 12 --width 64 \
        --placeholder "Поиск по истории…" 2>/dev/null) || exit 0

[[ -z "${entry}" ]] && exit 0

cliphist decode <<<"${entry}" | wl-copy
