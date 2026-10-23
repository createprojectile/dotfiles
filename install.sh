#!/usr/bin/env bash
# ============================================================================
#  Ayu Dark · установка дотфайлов для CachyOS / Arch + niri
# ----------------------------------------------------------------------------
#  Что делает:
#    1. ставит пакеты из официальных репозиториев (waybar, fuzzel, mako, ...);
#    2. делает бэкап существующих конфигов в ~/.config-backup-<дата>/;
#    3. симлинкует конфиги из этого репозитория в ~/.config;
#    4. генерирует qt6ct.conf и обои;
#    5. применяет настройки GTK/иконок/курсора через gsettings;
#    6. перезапускает bar/уведомления и перезагружает конфиг niri.
#
#  Использование:
#    ./install.sh                 # полная установка
#    ./install.sh --no-packages   # только разложить дотфайлы
#    ./install.sh --with-aur      # + Bibata cursor из AUR (через yay)
#    ./install.sh --sddm          # + тема экрана входа SDDM
#    ./install.sh --yes           # без вопросов
# ============================================================================
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config-backup-$STAMP"

INSTALL_PACKAGES=1
WITH_AUR=0
WITH_SDDM=0
ASSUME_YES=0

for arg in "$@"; do
    case "$arg" in
        --no-packages) INSTALL_PACKAGES=0 ;;
        --with-aur)    WITH_AUR=1 ;;
        --sddm)        WITH_SDDM=1 ;;
        --yes|-y)      ASSUME_YES=1 ;;
        --help|-h)     sed -n '2,30p' "$0"; exit 0 ;;
        *) echo "Неизвестный аргумент: $arg" >&2; exit 1 ;;
    esac
done

# --- Вывод ------------------------------------------------------------------
c_blue=$'\033[38;2;89;194;255m'
c_dim=$'\033[38;2;138;145;153m'
c_green=$'\033[38;2;170;217;76m'
c_red=$'\033[38;2;240;113;120m'
c_reset=$'\033[0m'

say()  { printf '%s::%s %s\n' "$c_blue" "$c_reset" "$*"; }
ok()   { printf '%s ✓%s %s\n' "$c_green" "$c_reset" "$*"; }
warn() { printf '%s !%s %s\n' "$c_red" "$c_reset" "$*"; }
die()  { warn "$*"; exit 1; }

confirm() {
    [[ $ASSUME_YES -eq 1 ]] && return 0
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

[[ $EUID -eq 0 ]] && die "Не запускайте от root: скрипт сам вызовет sudo там, где нужно."

# --- 1. Пакеты --------------------------------------------------------------
PACKAGES=(
    # бар и лаунчер
    waybar fuzzel
    # уведомления, обои, OSD
    mako swaybg swayosd
    # буфер обмена, скриншоты
    wl-clipboard cliphist grim slurp
    # блокировка и простой
    swayidle swaylock
    # медиа и звук
    playerctl brightnessctl pavucontrol libnotify
    # шрифты, иконки, темы
    ttf-jetbrains-mono-nerd inter-font adw-gtk-theme papirus-icon-theme
    # Qt
    qt6ct
    # утилиты
    imagemagick jq xdg-utils xdg-desktop-portal-gtk
)

install_packages() {
    command -v pacman >/dev/null || { warn "pacman не найден — пропускаю пакеты."; return; }

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        [[ "${ID:-}" =~ ^(cachyos|arch|garuda|endeavouros|manjaro)$ ]] || \
            warn "Дистрибутив ${ID:-?} не Arch-based — пакеты могут не установиться."
    fi

    say "Установка пакетов (${#PACKAGES[@]} шт.)"
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
    ok "Пакеты установлены"

    if [[ $WITH_AUR -eq 1 ]] && command -v yay >/dev/null; then
        say "Установка Bibata cursor из AUR"
        yay -S --needed --noconfirm bibata-cursor-theme-bin || \
            warn "Не удалось поставить Bibata — останется системный курсор."
    fi
}

# --- 2. Бэкап и симлинки ----------------------------------------------------
if [[ $INSTALL_PACKAGES -eq 1 ]]; then
    install_packages
else
    warn "Пакеты пропущены (--no-packages)"
fi

mkdir -p "$BACKUP"

backup_path() {
    local target="$1"
    [[ -e "$target" || -L "$target" ]] || return 0
    local rel="${target#"$HOME"/}"
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$target" "$BACKUP/$rel"
    ok "Бэкап: ~/$rel"
}

link_file() {
    local src="$1" dst="$2"
    [[ -e "$src" ]] || { warn "Нет файла $src"; return; }
    mkdir -p "$(dirname "$dst")"
    backup_path "$dst"
    ln -sfn "$src" "$dst"
}

link_dir() {
    local name="$1"          # имя каталога в config/
    local src="$DOTFILES/config/$name"
    local dst="$CONFIG/$name"
    [[ -d "$src" ]] || { warn "Нет каталога $src"; return; }
    backup_path "$dst"
    ln -sfn "$src" "$dst"
    ok "~/.config/$name → dotfiles/config/$name"
}

say "Раскладка дотфайлов (бэкап: $BACKUP)"

for d in niri waybar fuzzel mako alacritty swayosd swaylock btop fastfetch; do
    link_dir "$d"
done

# GTK: линкуем файлы, чтобы не потерять bookmarks и прочее.
for f in settings.ini gtk.css; do
    link_file "$DOTFILES/config/gtk-3.0/$f" "$CONFIG/gtk-3.0/$f"
    link_file "$DOTFILES/config/gtk-4.0/$f" "$CONFIG/gtk-4.0/$f"
done

# fish: только config.fish, остальное (fish_variables) не трогаем.
mkdir -p "$CONFIG/fish"
link_file "$DOTFILES/config/fish/config.fish" "$CONFIG/fish/config.fish"

# environment.d: только наш файл.
mkdir -p "$CONFIG/environment.d"
link_file "$DOTFILES/config/environment.d/10-ayu-style.conf" \
          "$CONFIG/environment.d/10-ayu-style.conf"

# Qt6ct: конфиг генерируется с абсолютным путём, цвета и qss — симлинки.
say "Настройка Qt (qt6ct)"
mkdir -p "$CONFIG/qt6ct/colors" "$CONFIG/qt6ct/qss"
link_file "$DOTFILES/config/qt6ct/colors/ayu-dark.conf" "$CONFIG/qt6ct/colors/ayu-dark.conf"
link_file "$DOTFILES/config/qt6ct/qss/ayu-dark.qss"   "$CONFIG/qt6ct/qss/ayu-dark.qss"
backup_path "$CONFIG/qt6ct/qt6ct.conf"
sed "s|@HOME@|$HOME|g" "$DOTFILES/config/qt6ct/qt6ct.conf.template" > "$CONFIG/qt6ct/qt6ct.conf"
ok "~/.config/qt6ct/qt6ct.conf"

# Скрипты.
say "Скрипты в ~/.local/bin"
mkdir -p "$HOME/.local/bin"
chmod +x "$DOTFILES"/local/bin/*.sh "$DOTFILES"/scripts/*.sh 2>/dev/null || true
for script in "$DOTFILES"/local/bin/*.sh; do
    name="$(basename "$script")"
    link_file "$script" "$HOME/.local/bin/$name"
    ok "~/.local/bin/$name"
done

# Обои.
say "Обои"
mkdir -p "$HOME/.local/share"
backup_path "$HOME/.local/share/wallpapers"
ln -sfn "$DOTFILES/wallpapers" "$HOME/.local/share/wallpapers"
if [[ ! -f "$DOTFILES/wallpapers/ayu-dark.png" ]]; then
    "$DOTFILES/scripts/generate-wallpapers.sh" "$DOTFILES/wallpapers"
fi
ok "~/.local/share/wallpapers → dotfiles/wallpapers"

# --- 3. GTK / шрифты / курсор ----------------------------------------------
apply_gsettings() {
    command -v gsettings >/dev/null || return 0
    [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]] || { warn "Нет DBus-сессии — gsettings пропущены."; return 0; }

    say "Применение темы GTK, иконок и курсора"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-name 'Inter 10' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface document-font-name 'Inter 10' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10' 2>/dev/null || true
    gsettings set org.gnome.desktop.wm.preferences button-layout ':close' 2>/dev/null || true
    ok "Тема применена"
}

apply_gsettings
fc-cache -f >/dev/null 2>&1 || true

# --- 4. Проверка и перезапуск ----------------------------------------------
if [[ -x /usr/bin/niri ]]; then
    if niri validate -c "$CONFIG/niri/config.kdl" >/dev/null 2>&1; then
        ok "Конфиг niri валиден"
    else
        warn "Конфиг niri не прошёл валидацию:"
        niri validate -c "$CONFIG/niri/config.kdl" || true
    fi
fi

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    say "Перезапуск компонентов"
    mkdir -p "$HOME/.cache"

    pkill -x waybar 2>/dev/null || true
    sleep 0.3
    setsid waybar >"$HOME/.cache/waybar.log" 2>&1 < /dev/null &
    ok "waybar запущен (лог: ~/.cache/waybar.log)"

    pkill -x mako 2>/dev/null || true
    setsid mako >/dev/null 2>&1 < /dev/null &
    ok "mako запущен"

    pkill -x swayosd-server 2>/dev/null || true
    setsid swayosd-server >/dev/null 2>&1 < /dev/null &
    ok "swayosd-server запущен"

    "$HOME/.local/bin/wallpaper.sh" >/dev/null 2>&1 &
    ok "Обои применены"

    niri msg action load-config-file >/dev/null 2>&1 && ok "Конфиг niri перезагружен" || true
fi

# --- 5. SDDM (опционально) --------------------------------------------------
if [[ $WITH_SDDM -eq 1 ]]; then
    say "Установка темы SDDM"
    sudo install -d /usr/share/sddm/themes/ayu
    sudo cp -r "$DOTFILES/system/sddm/ayu/." /usr/share/sddm/themes/ayu/
    sudo cp "$DOTFILES/wallpapers/ayu-dark.png" /usr/share/sddm/themes/ayu/background.png
    sudo install -d /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/10-ayu-theme.conf >/dev/null <<'EOF'
[Theme]
Current=ayu
EOF
    ok "Тема SDDM установлена"
    warn "Проверьте её ДО перезагрузки: sddm-greeter --test-mode --theme /usr/share/sddm/themes/ayu"
    warn "Откат: sudo rm /etc/sddm.conf.d/10-ayu-theme.conf"
fi

# --- Итог -------------------------------------------------------------------
cat <<EOF

${c_green}Готово.${c_reset}

  Бэкап старых конфигов : $BACKUP
  Дотфайлы              : $DOTFILES
  Бар                   : waybar (сверху, высота 34px)
  Лаунчер               : Mod+D / Mod+Space
  Меню питания          : Mod+Shift+E
  Скриншот области      : Mod+Shift+S
  Буфер обмена          : Mod+V

${c_dim}Если бар не появился: waybar > ~/.cache/waybar.log 2>&1${c_reset}
${c_dim}Перезагрузка конфига niri: niri msg action load-config-file${c_reset}

EOF
