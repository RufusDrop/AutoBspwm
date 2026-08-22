#!/usr/bin/env bash
# Power menu used by the Polybar button in the isolated AutoBspwm session.
set -u

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/autobspwm"
mkdir -p "$cache_dir"
exec 2>>"$cache_dir/powermenu.log"

lock='▣  Bloquear'
suspend='◐  Suspender'
logout='⇥  Cerrar sesión'
reboot='↻  Reiniciar'
shutdown='⏻  Apagar'

choice="$({
  printf '%s\n' "$lock" "$suspend" "$logout" "$reboot" "$shutdown"
} | rofi -dmenu -i -p 'Sistema' -selected-row 0)" || exit 0

case "$choice" in
  "$shutdown") systemctl poweroff ;;
  "$reboot") systemctl reboot ;;
  "$suspend") systemctl suspend ;;
  "$logout")
    # BSPWM is the process owned by the X session. Asking it to quit lets the
    # display manager close the session cleanly instead of killing every user
    # process with SIGKILL.
    bspc quit
    ;;
  "$lock")
    if command -v xflock4 >/dev/null 2>&1; then
      xflock4
    elif command -v i3lock >/dev/null 2>&1; then
      i3lock
    elif [[ -n ${XDG_SESSION_ID:-} ]]; then
      loginctl lock-session "$XDG_SESSION_ID"
    else
      loginctl lock-session
    fi
    ;;
esac
