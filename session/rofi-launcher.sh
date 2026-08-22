#!/usr/bin/env bash
set -euo pipefail

style_file="$HOME/.config/autobspwm/rofi-style"
style="$(sed -n '1p' "$style_file" 2>/dev/null || true)"
case "$style" in
  lista|compacto|rejilla) ;;
  *) style=lista ;;
esac

exec rofi -no-config -show drun -theme "$XDG_CONFIG_HOME/rofi/styles/$style.rasi"
