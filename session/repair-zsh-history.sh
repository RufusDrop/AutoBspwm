#!/usr/bin/env bash
# Recover a corrupt Zsh history while retaining an untouched timestamped copy.
set -euo pipefail

history_file="$HOME/.zsh_history"
[[ -s "$history_file" ]] || exit 0

check_history() {
  local output
  output="$(zsh -f -c 'fc -R "$1"' zsh "$1" 2>&1 || true)"
  ! grep -qi 'corrupt history file' <<<"$output"
}

check_history "$history_file" && exit 0

timestamp="$(date +%Y%m%d-%H%M%S)"
backup="$history_file.autobspwm-corrupt-$timestamp"
temporary="$history_file.autobspwm-recovered-$$"
cp -a -- "$history_file" "$backup"

# NUL bytes are the usual cause after an unclean VM shutdown. Removing only
# those bytes preserves UTF-8 commands and extended-history timestamps.
tr -d '\000' <"$backup" >"$temporary"
if ! check_history "$temporary"; then
  strings "$backup" >"$temporary"
fi
if ! check_history "$temporary"; then
  rm -f -- "$temporary"
  echo "Aviso: no se pudo reparar .zsh_history; el original no se ha modificado." >&2
  exit 0
fi

chmod 600 "$temporary"
mv -f -- "$temporary" "$history_file"
printf 'Historial Zsh reparado. Original intacto en: %s\n' "$backup"
