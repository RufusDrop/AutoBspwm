#!/usr/bin/env bash
# Copy the IPv4 currently displayed by one of AutoBspwm's Polybar modules.
set -euo pipefail

config_home="${XDG_CONFIG_HOME:?AutoBspwm no está activo}"
case "${1:-}" in
  local)  source_script="$config_home/bin/ethernet_status.sh" ;;
  vpn)    source_script="$config_home/bin/htb_status.sh" ;;
  target) source_script="$config_home/bin/htb_target.sh" ;;
  *)
    echo "Uso: copy-polybar-ip {local|vpn|target}" >&2
    exit 2
    ;;
esac

if [[ ! -x $source_script ]]; then
  echo "No se puede consultar la IP: $source_script" >&2
  exit 1
fi

module_output="$($source_script 2>/dev/null || true)"
ip="$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' <<<"$module_output" | head -n1 || true)"
if [[ -z $ip ]]; then
  command -v notify-send >/dev/null 2>&1 && \
    notify-send 'AutoBspwm' 'No hay ninguna IP disponible para copiar.'
  exit 0
fi

if ! command -v xclip >/dev/null 2>&1; then
  command -v notify-send >/dev/null 2>&1 && \
    notify-send 'AutoBspwm' 'No se encontró xclip.'
  exit 1
fi

printf '%s' "$ip" | xclip -selection clipboard
if command -v notify-send >/dev/null 2>&1; then
  notify-send 'IP copiada' "$ip" 2>/dev/null || true
fi
