# ============================================================================
#  fish · Ayu Dark
#  Базовая конфигурация CachyOS + аккуратный промпт pure в цветах Ayu.
# ============================================================================

source /usr/share/cachyos-fish-config/cachyos-config.fish

# --- Палитра pure prompt ------------------------------------------------
set -g pure_color_primary          59c2ff
set -g pure_color_current_directory 59c2ff
set -g pure_color_info             95e6cb
set -g pure_color_mute             565b66
set -g pure_color_success          d2a6ff
set -g pure_color_normal           bfbdb6
set -g pure_color_light            e6e1cf
set -g pure_color_dark             0a0e14
set -g pure_color_danger           f07178
set -g pure_color_warning          e6b450
set -g pure_color_git_branch       8a9199
set -g pure_color_git_dirty        8a9199
set -g pure_enable_single_line_prompt true
set -g pure_symbol_prompt          "❯"

# --- Цвета fish (автодополнение, подсветка, выбор) ----------------------
set -g fish_color_normal           bfbdb6
set -g fish_color_command          59c2ff
set -g fish_color_keyword          d2a6ff
set -g fish_color_param            bfbdb6
set -g fish_color_quote            95e6cb
set -g fish_color_redirection      e6b450
set -g fish_color_end              8a9199
set -g fish_color_error            f07178
set -g fish_color_comment          565b66
set -g fish_color_selection        --background=1f2630
set -g fish_color_search_match     --background=1f2630
set -g fish_color_operator         ffb454
set -g fish_color_escape           ffb454
set -g fish_color_autosuggestion   565b66
set -g fish_color_cwd              59c2ff
set -g fish_color_cwd_root         f07178

# --- Приветствие --------------------------------------------------------
function fish_greeting
    fastfetch
end

# --- Утилиты ------------------------------------------------------------
alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -l --group-directories-first --icons=auto --git'
alias la='eza -la --group-directories-first --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'
alias cat='bat --style=plain'
alias grep='grep --color=auto'
alias vim='nvim'

# Быстрый поиск по истории.
function history
    builtin history --show-time='%F %T ' $argv
end
