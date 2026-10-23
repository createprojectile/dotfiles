# Ayu Dark · niri + Waybar dotfiles

Минималистичное оформление CachyOS на niri в единой палитре **Ayu Dark**:
сплошной бар сверху, лаунчер fuzzel, уведомления mako, терминал alacritty,
GTK/Qt в тех же цветах и модульный конфиг niri.

```
  bar     waybar · 34px · сверху · сплошная полоса
  launcher fuzzel · Mod+D / Mod+Space
  notify  mako · правый верхний угол
  term    alacritty · JetBrainsMono Nerd Font
  login   SDDM · тема ayu (опционально)
```

---

## Палитра

| Роль | Цвет | |
|------|------|---|
| Фон | `#0a0e14` | ██ |
| Поверхность | `#11151c` | ██ |
| Границы | `#1f2630` | ██ |
| Текст | `#bfbdb6` | ██ |
| Приглушённый | `#8a9199` | ██ |
| Акцент (синий) | `#59c2ff` | ██ |
| Бирюзовый | `#95e6cb` | ██ |
| Зелёный | `#aad94c` | ██ |
| Жёлтый | `#e6b450` | ██ |
| Оранжевый | `#ffb454` | ██ |
| Красный | `#f07178` | ██ |
| Фиолетовый | `#d2a6ff` | ██ |

Цвета продублированы в конфигах каждого приложения — см. раздел «Кастомизация».

---

## Структура

```
dotfiles/
├── install.sh                  # установка (пакеты + симлинки + тема)
├── README.md
├── config/
│   ├── niri/
│   │   ├── config.kdl          # точка входа, только include
│   │   └── modules/
│   │       ├── environment.kdl # env сессии, курсор, NVIDIA, скриншоты
│   │       ├── input.kdl       # клавиатура us/ru, тачпад, мышь
│   │       ├── outputs.kdl     # DP-1 200Hz + HDMI-A-1 60Hz
│   │       ├── layout.kdl      # gaps, focus-ring, тени, скругления
│   │       ├── animations.kdl  # анимации
│   │       ├── rules.kdl       # плавающие диалоги, приватность
│   │       ├── autostart.kdl   # waybar, mako, обои, cliphist, swayidle
│   │       └── binds.kdl       # горячие клавиши
│   ├── waybar/                 # config.jsonc + style.css
│   ├── fuzzel/fuzzel.ini
│   ├── mako/config
│   ├── alacritty/alacritty.toml
│   ├── gtk-3.0/  gtk-4.0/      # settings.ini + gtk.css (цвета Adwaita)
│   ├── qt6ct/                  # палитра и QSS для Qt6
│   ├── swayosd/style.css       # OSD громкости/яркости
│   ├── swaylock/config
│   ├── btop/                   # конфиг + тема ayu
│   ├── fastfetch/config.jsonc
│   ├── fish/config.fish
│   └── environment.d/          # переменные для systemd --user
├── local/bin/                  # wallpaper / clipboard / power-menu / screenshot
├── wallpapers/                 # ayu-dark.png + ayu-dark-alt.png
├── scripts/
│   ├── backup.sh               # снимок текущих дотфайлов в backup/
│   ├── restore.sh              # откат из ~/.config-backup-*
│   └── generate-wallpapers.sh  # перегенерация обоев
├── system/sddm/ayu/            # тема экрана входа
└── backup/<дата>/              # исходные конфиги до установки
```

Всё в `~/.config` — **симлинки** на этот репозиторий: правите файл здесь —
изменение сразу в системе. Исключения: `fish/config.fish`, GTK-файлы и
`environment.d` линкуются пофайлово, чтобы не затереть чужие настройки.

---

## Установка

```bash
cd ~/dotfiles
./install.sh                 # пакеты + дотфайлы + тема
./install.sh --no-packages   # только разложить конфиги
./install.sh --with-aur      # + курсор Bibata из AUR (yay)
./install.sh --sddm          # + тема экрана входа SDDM
```

Скрипт:

1. ставит пакеты из официальных репозиториев CachyOS/Arch;
2. переносит существующие конфиги в `~/.config-backup-<дата>/`;
3. создаёт симлинки, генерирует `qt6ct.conf`, кладёт обои;
4. применяет тему GTK, иконки Papirus-Dark, курсор, шрифты через `gsettings`;
5. проверяет конфиг niri (`niri validate`) и перезапускает `waybar`, `mako`,
   `swayosd-server`, обои, перезагружает конфиг niri.

Пакеты: `waybar fuzzel mako swaybg swayosd wl-clipboard cliphist grim slurp
swayidle swaylock playerctl brightnessctl pavucontrol libnotify
ttf-jetbrains-mono-nerd inter-font adw-gtk-theme papirus-icon-theme qt6ct
imagemagick jq xdg-utils xdg-desktop-portal-gtk`.

> Скрипт не запускается от root: `sudo` вызывается только для pacman/SDDM.

---

## Горячие клавиши

`Mod` = **Super**.

| Клавиши | Действие |
|---|---|
| `Mod+Return` / `Mod+T` | alacritty |
| `Mod+D` / `Mod+Space` | fuzzel (лаунчер) |
| `Mod+V` | история буфера (cliphist + fuzzel) |
| `Mod+Shift+E` | меню питания |
| `Mod+Shift+S` | скриншот области → файл + буфер |
| `Print` | скриншот UI niri |
| `Mod+Shift+L` | заблокировать (swaylock) |
| `Mod+Shift+O` | погасить экраны |
| `Mod+Q` | закрыть окно |
| `Mod+F` / `Mod+Shift+F` | максимизировать / fullscreen |
| `Mod+Shift+V` | плавающее окно |
| `Mod+R` | пресеты ширины колонки |
| `Mod+←↓↑→` / `Mod+HJKL` | фокус |
| `Mod+Ctrl+←↓↑→` | перемещение окна |
| `Mod+Shift+←↓↑→` | фокус на другой монитор |
| `Mod+1…9` | рабочее пространство 1…9 |
| `Mod+Shift+1…9` | переместить окно на пространство |
| `Mod+O` | обзор |
| `Mod+Shift+/` | список горячих клавиш |
| `XF86Audio*` | громкость (OSD swayosd) |
| `XF86MonBrightness*` | яркость (OSD swayosd) |

---

## Модули и как их править

### niri

`config.kdl` содержит только `include`. Правьте нужный файл в
`config/niri/modules/`, затем:

```bash
niri validate -c ~/.config/niri/config.kdl   # проверка
niri msg action load-config-file             # перезагрузка
```

Мониторы — `modules/outputs.kdl`. Имена выходов смотрите в `niri msg outputs`.
Если монитор другой, поменяйте `mode`/`position`; лишнюю секцию можно удалить.

Клавиатура — `modules/input.kdl` (`layout "us,ru"`).

### Waybar

- `config/waybar/config.jsonc` — состав модулей, интервалы, действия по клику.
- `config/waybar/style.css` — вся визуальная часть, палитра в `@define-color`
  в начале файла.

Клик по сети открывает `nmtui` в терминале, по звуку — `pavucontrol`,
по CPU/RAM — `btop`, по кнопке питания — меню fuzzel.

Перезапуск: `pkill waybar; waybar &` (лог: `~/.cache/waybar.log`).

### fuzzel

`config/fuzzel/fuzzel.ini`. Цвета — в секции `[colors]` (формат `RRGGBBAA`
без `#`). Размер/шрифт — в `[main]`.

### mako

`config/mako/config`, формат `ключ=значение`. Перезапуск: `pkill mako; mako &`.

### Alacritty

`config/alacritty/alacritty.toml` — тема `[colors.*]`, шрифт, прозрачность
(`window.opacity`). Украшения отключены (`decorations = "none"`) — niri сам
рисует рамку и тень.

### GTK / Qt

- GTK: `config/gtk-3.0/` и `config/gtk-4.0/` — `settings.ini` и `gtk.css`.
  `gtk.css` переопределяет именованные цвета Adwaita, поэтому libadwaita-
  приложения тоже становятся тёмно-синими.
- Qt6: `config/qt6ct/colors/ayu-dark.conf` (палитра QPalette) и
  `config/qt6ct/qss/ayu-dark.qss` (скругления, поля, меню).
  Применяется через `QT_QPA_PLATFORMTHEME=qt6ct`.

### SDDM

Тема лежит в `system/sddm/ayu/`. Устанавливается флагом `--sddm`:

```bash
./install.sh --sddm
sddm-greeter --test-mode --theme /usr/share/sddm/themes/ayu   # проверить
```

Откат: `sudo rm /etc/sddm.conf.d/10-ayu-theme.conf`.

### Обои

`wallpapers/ayu-dark.png` (DP-1) и `ayu-dark-alt.png` (HDMI-A-1) генерируются
скриптом `scripts/generate-wallpapers.sh` (ImageMagick). Свои картинки просто
положите с теми же именами или поправьте пути в `local/bin/wallpaper.sh`.

Применить: `~/.local/bin/wallpaper.sh`.

---

## Бэкап и откат

- Перед установкой `install.sh` переносит старые конфиги в
  `~/.config-backup-<дата>/`.
- Исходные конфиги этой системы также сохранены в `backup/<дата>/`.
- Снимок текущего состояния в репозиторий:

  ```bash
  ./scripts/backup.sh
  ```

- Откат:

  ```bash
  ./scripts/restore.sh ~/.config-backup-20261024-001500
  ```

  Скрипт удаляет симлинки в `~/.config`, ведущие в `dotfiles`, и копирует
  файлы из бэкапа обратно.

Полностью убрать дотфайлы:

```bash
rm ~/.config/{niri,waybar,fuzzel,mako,alacritty,swayosd,swaylock,btop,fastfetch}
rm ~/.local/bin/{wallpaper,clipboard,power-menu,screenshot}.sh
```

---

## Диагностика

| Проблема | Что сделать |
|---|---|
| Бар не появился | `waybar > ~/.cache/waybar.log 2>&1` и смотрите лог |
| Иконки — квадраты | `pacman -S ttf-jetbrains-mono-nerd && fc-cache -f` |
| Нет звука в баре | `wpctl status`, проверьте `pulseaudio` модуль |
| Скриншоты не работают | `grim -g "$(slurp)" test.png` вручную |
| Не применяется тема GTK | `gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark` |
| Кривой конфиг niri | `niri validate` — покажет файл и строку |
| После правки include нет эффекта | `niri msg action load-config-file` |
| Waybar показывает чужие workspace | модуль `niri/workspaces`, параметр `all-outputs` |

Логи: `~/.cache/waybar.log`, `journalctl --user -b`, `niri msg outputs`.

---

## Что изменено в системе

- пакеты из списка выше;
- `~/.config/*` — симлинки на этот репозиторий;
- `~/.local/bin/*.sh` — симлинки на скрипты;
- `~/.local/share/wallpapers` — симлинк на `wallpapers/`;
- `gsettings` — тёмная схема, adw-gtk3-dark, Papirus-Dark, Inter,
  JetBrainsMono Nerd Font, Bibata (если установлен);
- опционально `/usr/share/sddm/themes/ayu` и `/etc/sddm.conf.d/10-ayu-theme.conf`.
