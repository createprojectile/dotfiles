#!/usr/bin/env bash
# ============================================================================
#  Снимок текущих дотфайлов в dotfiles/backup/<дата>/
#  Используется перед экспериментами: ./scripts/backup.sh
# ============================================================================
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
DEST="$DOTFILES/backup/$STAMP"

mkdir -p "$DEST"

paths=(
    ".config/niri"
    ".config/waybar"
    ".config/fuzzel"
    ".config/mako"
    ".config/alacritty"
    ".config/gtk-3.0"
    ".config/gtk-4.0"
    ".config/qt6ct"
    ".config/swayosd"
    ".config/swaylock"
    ".config/btop"
    ".config/fastfetch"
    ".config/fish/config.fish"
    ".config/environment.d"
    ".local/bin"
)

for p in "${paths[@]}"; do
    [[ -e "$HOME/$p" || -L "$HOME/$p" ]] || continue
    mkdir -p "$DEST/$(dirname "$p")"
    cp -a --no-dereference "$HOME/$p" "$DEST/$p" 2>/dev/null || true
done

echo "Бэкап сохранён: $DEST"
