#!/usr/bin/env bash
# ============================================================================
#  Восстановление конфигов из бэкапа.
#  ./scripts/restore.sh ~/.config-backup-20261024-001500
#  или без аргумента — покажет список доступных бэкапов.
# ============================================================================
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Доступные бэкапы:"
    ls -1d "$HOME"/.config-backup-* 2>/dev/null || echo "  (нет)"
    echo
    echo "Использование: $0 <путь-к-бэкапу>"
    exit 1
fi

SRC="$1"
[[ -d "$SRC" ]] || { echo "Нет такого каталога: $SRC" >&2; exit 1; }

read -r -p "Заменить текущие конфиги содержимым $SRC? [y/N] " reply
[[ "$reply" =~ ^[Yy]$ ]] || exit 0

# Удаляем симлинки, которые ведут в dotfiles, чтобы cp не писал в репозиторий.
while IFS= read -r -d '' link; do
    target="$(readlink "$link")"
    [[ "$target" == *"/dotfiles/"* ]] && rm -f "$link"
done < <(find "$HOME/.config" -maxdepth 3 -type l -print0 2>/dev/null || true)

cp -a "$SRC/." "$HOME/"

echo "Восстановлено из $SRC"
echo "Перезагрузите конфиг niri: niri msg action load-config-file"
