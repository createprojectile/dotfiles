#!/usr/bin/env bash
# ============================================================================
#  Меню питания (fuzzel). Mod+Shift+E, клик по кнопке питания на баре.
# ============================================================================
set -euo pipefail

choice=$(printf '%s\n' \
    "  Заблокировать" \
    "  Выйти из niri" \
    "  Спящий режим" \
    "  Перезагрузить" \
    "  Выключить" \
    | fuzzel --dmenu --prompt "  " --lines 5 --width 26 2>/dev/null) || exit 0

case "${choice}" in
    *Заблокировать) swaylock -f ;;
    *Выйти)         niri msg action quit --skip-confirmation ;;
    *Спящий)        swaylock -f & sleep 0.4; systemctl suspend ;;
    *Перезагрузить) systemctl reboot ;;
    *Выключить)     systemctl poweroff ;;
esac
