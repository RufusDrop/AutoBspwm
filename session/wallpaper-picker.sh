#!/usr/bin/env bash
# Preview, apply and cycle through the active profile's wallpapers.
set -euo pipefail

mode="${1:-choose}"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
wallpaper_dir="${AUTOBSPWM_WALLPAPER_DIR:-$config_home/Wallpaper}"
profile_name="$(basename -- "$config_home")"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/autobspwm"
state_file="$state_dir/wallpaper-$profile_name"

mapfile -d '' wallpapers < <(
  find "$wallpaper_dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o \
       -iname '*.webp' -o -iname '*.bmp' \) -print0 2>/dev/null | sort -z
)

if (( ${#wallpapers[@]} == 0 )); then
  command -v notify-send >/dev/null 2>&1 && \
    notify-send 'AutoBspwm' "No hay imágenes en $wallpaper_dir"
  exit 1
fi

current="$(sed -n '1p' "$state_file" 2>/dev/null || true)"
current_index=-1
for index in "${!wallpapers[@]}"; do
  if [[ ${wallpapers[$index]} == "$current" ]]; then
    current_index=$index
    break
  fi
done

if (( current_index < 0 )); then
  default_name="$(sed -n '1p' "$wallpaper_dir/.default" 2>/dev/null || true)"
  for index in "${!wallpapers[@]}"; do
    if [[ $(basename -- "${wallpapers[$index]}") == "$default_name" ]]; then
      current_index=$index
      break
    fi
  done
fi
(( current_index >= 0 )) || current_index=0

apply_wallpaper() {
  local wallpaper=$1 temporary
  feh --no-fehbg --bg-fill "$wallpaper"
  install -d "$state_dir"
  temporary="$state_file.$$"
  printf '%s\n' "$wallpaper" >"$temporary"
  mv -f -- "$temporary" "$state_file"
}

case "$mode" in
  startup)
    apply_wallpaper "${wallpapers[$current_index]}"
    ;;
  next)
    index=$(( (current_index + 1) % ${#wallpapers[@]} ))
    apply_wallpaper "${wallpapers[$index]}"
    ;;
  previous)
    index=$(( (current_index - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
    apply_wallpaper "${wallpapers[$index]}"
    ;;
  choose)
    command -v rofi >/dev/null 2>&1 || {
      echo "Rofi no está instalado; no se puede abrir el selector visual." >&2
      exit 1
    }
    selection="$({
      for wallpaper in "${wallpapers[@]}"; do
        printf '%s\0icon\x1f%s\n' "$(basename -- "$wallpaper")" "$wallpaper"
      done
    } | rofi -no-config -dmenu -i -show-icons \
      -selected-row "$current_index" -p 'Fondo de pantalla' \
      -theme "$config_home/rofi/wallpaper.rasi")" || exit 0

    for wallpaper in "${wallpapers[@]}"; do
      if [[ $(basename -- "$wallpaper") == "$selection" ]]; then
        apply_wallpaper "$wallpaper"
        exit 0
      fi
    done
    ;;
  *)
    echo "Uso: wallpaper-picker {choose|next|previous|startup}" >&2
    exit 2
    ;;
esac
