#!/usr/bin/env bash
# ============================================================================
#  Генерация обоев Ayu Dark (ImageMagick).
#  Запуск: ./scripts/generate-wallpapers.sh [outdir]
#  Создаёт: ayu-dark.png (DP-1) и ayu-dark-alt.png (HDMI-A-1)
#
#  Композиция: глубокий фон #0a0e14, мягкое синее свечение вверху слева и
#  фиолетовое внизу справа. Второй монитор — зеркальная композиция.
# ============================================================================
set -euo pipefail

OUT="${1:-$(cd "$(dirname "$0")/.." && pwd)/wallpapers}"
mkdir -p "$OUT"

W=1920
H=1080

# Бесшовный градиент: интерполяция по опорным точкам (без границ слоёв).
POINTS='0,0 #16293e  1920,0 #0c1119  0,1080 #090d13  1920,1080 #1d1428  960,380 #0f1c2a  1380,880 #251726'

magick -size ${W}x${H} xc: \
    -sparse-color shepards "$POINTS" \
    -define png:compression-level=9 \
    "$OUT/ayu-dark.png"

# Зеркальная версия для второго монитора, чуть спокойнее по насыщенности.
magick "$OUT/ayu-dark.png" \
    -flop \
    -modulate 100,94,100 \
    -define png:compression-level=9 \
    "$OUT/ayu-dark-alt.png"

echo "Готово: $OUT/ayu-dark.png, $OUT/ayu-dark-alt.png"
