#!/usr/bin/env sh
# Launch every bar used by the selected profile and keep actionable logs.
set -u

polybar_dir="${XDG_CONFIG_HOME:?}/polybar"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/autobspwm"
log_file="$cache_dir/polybar.log"
install -d "$cache_dir"
: >"$log_file"
{
  printf 'Perfil XDG: %s\n' "$XDG_CONFIG_HOME"
  polybar --version | head -n1
  printf 'Iosevka: '
  fc-match -f '%{family}\n' 'Iosevka Nerd Font' | head -n1
  printf 'Mountain: '
  fc-match -f '%{family}\n' 'AutoBspwm Mountain' | head -n1
} >>"$log_file" 2>&1

polybar-msg cmd quit >/dev/null 2>&1 || pkill -x polybar >/dev/null 2>&1 || true
attempt=0
while pgrep -u "$(id -u)" -x polybar >/dev/null 2>&1 && [ "$attempt" -lt 50 ]; do
  sleep 0.1
  attempt=$((attempt + 1))
done
if pgrep -u "$(id -u)" -x polybar >/dev/null 2>&1; then
  printf 'Polybar anterior no respondió a IPC; enviando SIGTERM.\n' >>"$log_file"
  pkill -TERM -u "$(id -u)" -x polybar >/dev/null 2>&1 || true
fi

launch_bar() {
  config=$1
  bar=$2
  if [ -r "$config" ] && grep -Fqx "[bar/$bar]" "$config"; then
    printf '\n=== %s (%s) ===\n' "$bar" "$config" >>"$log_file"
    polybar "$bar" -c "$config" >>"$log_file" 2>&1 &
  else
    printf 'No existe [bar/%s] en %s\n' "$bar" "$config" >>"$log_file"
  fi
}

current="$polybar_dir/current.ini"
printf '\n=== validación current.ini ===\n' >>"$log_file"
polybar -c "$current" --list-bars >>"$log_file" 2>&1 || true
for bar in log secondary terciary quaternary quinary top primary; do
  launch_bar "$current" "$bar"
done
printf '\n=== validación workspace.ini ===\n' >>"$log_file"
polybar -c "$polybar_dir/workspace.ini" --list-bars >>"$log_file" 2>&1 || true
launch_bar "$polybar_dir/workspace.ini" primary

printf 'Polybar iniciado. Registro: %s\n' "$log_file" >>"$log_file"
