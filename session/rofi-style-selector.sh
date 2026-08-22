#!/usr/bin/env bash
set -euo pipefail

choice="$(printf '%s\n' 'Lista' 'Compacto' 'Rejilla con iconos' |
  rofi -no-config -dmenu -i -p 'Estilo de aplicaciones')" || exit 0

case "$choice" in
  Lista) style=lista ;;
  Compacto) style=compacto ;;
  'Rejilla con iconos') style=rejilla ;;
  *) exit 0 ;;
esac

style_file="$HOME/.config/autobspwm/rofi-style"
install -d "$(dirname -- "$style_file")"
printf '%s\n' "$style" >"$style_file"
exec "$XDG_CONFIG_HOME/bin/rofi-launcher.sh"
