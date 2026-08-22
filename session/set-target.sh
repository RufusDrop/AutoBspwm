#!/usr/bin/env bash
set -euo pipefail

target_file="${XDG_CONFIG_HOME:?AutoBspwm no está activo}/bin/target"

case "${1:-}" in
  --clear|-c|clear)
    : >"$target_file"
    echo "Target eliminado."
    exit 0
    ;;
  '')
    if [[ -s "$target_file" ]]; then
      printf 'Target actual: '
      cat "$target_file"
    else
      echo 'No hay target configurado.'
    fi
    echo 'Uso: settarget IP [NOMBRE] | cleartarget'
    exit 0
    ;;
esac

ip=$1
shift
if [[ ! $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "IP no válida: $ip" >&2
  exit 2
fi

printf '%s' "$ip" >"$target_file"
if [[ $# -gt 0 ]]; then
  printf ' %s' "$*" >>"$target_file"
fi
printf '\n' >>"$target_file"
printf 'Target configurado: '
cat "$target_file"
