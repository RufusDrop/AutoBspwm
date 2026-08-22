#!/usr/bin/env bash
# Apply one profile without deleting unrelated user configuration.
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "Ejecuta theme.sh con tu usuario normal, sin sudo." >&2
  exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
themes=(Pacman Parrot S4vi Cinnamoroll Pink ZLCube Legion Kazerg Zeneapp Matterhorn Nord)

theme_config_dir() {
  local theme=$1
  if [[ -d "$repo_dir/Themes/$theme/Config" ]]; then
    printf '%s\n' "$repo_dir/Themes/$theme/Config"
  elif [[ -d "$repo_dir/Themes/$theme/config" ]]; then
    printf '%s\n' "$repo_dir/Themes/$theme/config"
  else
    return 1
  fi
}

choose_theme() {
  if [[ $# -gt 0 ]]; then
    printf '%s\n' "$1"
  elif command -v zenity >/dev/null 2>&1 && [[ -n ${DISPLAY:-} ]]; then
    zenity --list --title='AutoBspwm: seleccionar perfil' \
      --column='Perfil' --height=480 "${themes[@]}"
  else
    PS3='Perfil: '
    select selected in "${themes[@]}"; do
      [[ -n ${selected:-} ]] && { printf '%s\n' "$selected"; return; }
      echo 'Selección no válida.' >&2
    done
  fi
}

if [[ $# -gt 0 ]]; then
  profile="$1"
else
  profile="$(choose_theme)" || exit 0
fi
if [[ ! " ${themes[*]} " =~ " $profile " ]]; then
  echo "Perfil no válido: $profile" >&2
  exit 2
fi

source_dir="$(theme_config_dir "$profile")" || {
  echo "El perfil $profile no tiene directorio de configuración." >&2
  exit 1
}

timestamp="$(date +%Y%m%d-%H%M%S)-$$"
backup_dir="$HOME/.config/autobspwm-backups/$timestamp"
managed=(bspwm bin picom polybar Wallpaper wallpapers)
install -d "$backup_dir"

for item in "${managed[@]}"; do
  if [[ -e "$HOME/.config/$item" ]]; then
    mv "$HOME/.config/$item" "$backup_dir/$item"
  fi
done

for item in "${managed[@]}"; do
  if [[ -e "$source_dir/$item" ]]; then
    cp -a "$source_dir/$item" "$HOME/.config/"
  fi
done

# VMware images now use open-vm-tools' vmware-user binary. Older profiles
# called a removed wrapper and produced an error at every BSPWM login.
bspwmrc="$HOME/.config/bspwm/bspwmrc"
if [[ -f "$bspwmrc" ]]; then
  sed -i 's|^[[:space:]]*vmware-user-suid-wrapper[[:space:]]*\&[[:space:]]*$|command -v vmware-user >/dev/null 2>\&1 \&\& vmware-user \&|' "$bspwmrc"
fi

# Persist user preferences outside theme directories so switching profiles does
# not reset them. New installs keep the requested Spanish (Spain) layout.
local_dir="$HOME/.config/autobspwm"
local_file="$local_dir/local.sh"
install -d "$local_dir"
if [[ ! -f "$local_file" ]]; then
  cat >"$local_file" <<'EOF'
#!/usr/bin/env sh
# Local preferences preserved by AutoBspwm when changing profiles.
# Change this line if you later want a different XKB layout.
setxkbmap -layout es -variant '' -option ''
EOF
  chmod 700 "$local_file"
fi

if [[ -f "$bspwmrc" ]] && ! grep -Fq 'autobspwm/local.sh' "$bspwmrc"; then
  cat >>"$bspwmrc" <<'EOF'

# Keep local keyboard and other personal preferences across profile changes.
[ -r "$HOME/.config/autobspwm/local.sh" ] && . "$HOME/.config/autobspwm/local.sh"
EOF
fi

find "$HOME/.config/bspwm" -type f -name 'bspwmrc' -exec chmod 700 {} + 2>/dev/null || true
find "$HOME/.config/bspwm/scripts" -type f -exec chmod 700 {} + 2>/dev/null || true
find "$HOME/.config/bin" -type f -name '*.sh' -exec chmod 700 {} + 2>/dev/null || true
find "$HOME/.config/polybar" -type f -name '*.sh' -exec chmod 700 {} + 2>/dev/null || true

echo "Perfil $profile aplicado. Copia de seguridad: $backup_dir"
echo "El teclado español se carga desde $local_file"
echo "Cierra la sesión y elige BSPWM o la sesión predeterminada de Kali en LightDM."
