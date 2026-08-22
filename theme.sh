#!/usr/bin/env bash
# Install a profile privately. It is loaded only by the AutoBspwm X session.
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "Ejecuta theme.sh con tu usuario normal, sin sudo." >&2
  exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
autobspwm_dir="$config_home/autobspwm"
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
  if command -v zenity >/dev/null 2>&1 && [[ -n ${DISPLAY:-} ]]; then
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
  profile=$1
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

profiles_dir="$autobspwm_dir/profiles"
profile_dir="$profiles_dir/$profile"
timestamp="$(date +%Y%m%d-%H%M%S)-$$"
backup_dir="$config_home/autobspwm-backups/$timestamp"
install -d "$profiles_dir" "$backup_dir"

if [[ -e "$profile_dir" ]]; then
  mv "$profile_dir" "$backup_dir/$profile"
fi
cp -a "$source_dir/." "$profile_dir/"
# sxhkd follows XDG_CONFIG_HOME too; place the shared key bindings beside the
# profile so Super+Enter, Super+D and workspace shortcuts work in AutoBspwm.
if [[ ! -f "$profile_dir/sxhkd/sxhkdrc" ]]; then
  install -Dm644 "$repo_dir/Config/sxhkd/sxhkdrc" "$profile_dir/sxhkd/sxhkdrc"
fi

# BSPWM inherits XDG_CONFIG_HOME from the dedicated AutoBspwm session. Convert
# legacy hard-coded paths so every profile stays below ~/.config/autobspwm.
while IFS= read -r -d '' file; do
  case "$file" in
    */bspwm/bspwmrc|*/bin/*|*/polybar/launch.sh|*/polybar/scripts/*)
      sed -i \
        -e 's|~/.config/|$XDG_CONFIG_HOME/|g' \
        -e 's|\$HOME/.config/|$XDG_CONFIG_HOME/|g' "$file"
      ;;
    *.ini|*/polybar/config)
      sed -i \
        -e 's|~/.config/|${env:XDG_CONFIG_HOME}/|g' \
        -e 's|\$HOME/.config/|${env:XDG_CONFIG_HOME}/|g' "$file"
      ;;
  esac
done < <(find "$profile_dir" -type f -not -path '*/fonts/*' -print0)

# Picom 12 removed refresh-rate. Leaving the old option displays an intrusive
# warning dialog and prevents the intended compositor behaviour.
find "$profile_dir" -path '*/picom/picom.conf' -type f -exec \
  sed -i '/^[[:space:]]*refresh-rate[[:space:]]*=/d' {} +

# open-vm-tools exposes vmware-user, not the obsolete suid wrapper.
bspwmrc="$profile_dir/bspwm/bspwmrc"
if [[ -f "$bspwmrc" ]]; then
  sed -i 's|^[[:space:]]*vmware-user-suid-wrapper[[:space:]]*\&[[:space:]]*$|command -v vmware-user >/dev/null 2>\&1 \&\& vmware-user \&|' "$bspwmrc"
  cat >>"$bspwmrc" <<'EOF'

# Kept outside individual profiles, so a profile switch preserves the layout.
[ -r "$HOME/.config/autobspwm/local.sh" ] && . "$HOME/.config/autobspwm/local.sh"
EOF
fi

# These files are visible only while the AutoBspwm session sets XDG_CONFIG_HOME
# and ZDOTDIR. The normal Kali desktop continues to use its own terminal setup.
install -d "$profile_dir/kitty" "$profile_dir/zsh"
cat >"$profile_dir/kitty/kitty.conf" <<'EOF'
font_family Iosevka Nerd Font
background_opacity 0.88
dynamic_background_opacity yes
EOF
cat >"$profile_dir/zsh/.zshrc" <<'EOF'
autoload -Uz compinit
compinit
for p10k_theme in \
  /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme \
  /usr/share/powerlevel10k/powerlevel10k.zsh-theme; do
  [[ -r "$p10k_theme" ]] && source "$p10k_theme" && break
done
[[ -r "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"
[[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
EOF
if [[ -f "$repo_dir/Themes/$profile/.p10k.zsh" ]]; then
  cp -a "$repo_dir/Themes/$profile/.p10k.zsh" "$profile_dir/zsh/.p10k.zsh"
elif [[ -f "$repo_dir/Themes/ZLCube/.p10k.zsh" ]]; then
  cp -a "$repo_dir/Themes/ZLCube/.p10k.zsh" "$profile_dir/zsh/.p10k.zsh"
fi

local_file="$autobspwm_dir/local.sh"
if [[ ! -f "$local_file" ]]; then
  cat >"$local_file" <<'EOF'
#!/usr/bin/env sh
# Local preferences preserved by AutoBspwm when changing profiles.
setxkbmap -layout es -variant '' -option ''
EOF
  chmod 700 "$local_file"
fi

ln -sfn "profiles/$profile" "$autobspwm_dir/active"
find "$profile_dir/bspwm" -type f -name 'bspwmrc' -exec chmod 700 {} + 2>/dev/null || true
find "$profile_dir/bspwm/scripts" -type f -exec chmod 700 {} + 2>/dev/null || true
find "$profile_dir/bin" -type f -name '*.sh' -exec chmod 700 {} + 2>/dev/null || true
find "$profile_dir/polybar" -type f -name '*.sh' -exec chmod 700 {} + 2>/dev/null || true

echo "Perfil $profile instalado en $profile_dir"
echo "En LightDM elige la sesión 'AutoBspwm', no la entrada BSPWM genérica."
if command -v rofi-theme-selector >/dev/null 2>&1 && [[ -n ${DISPLAY:-} ]]; then
  rofi-theme-selector || true
else
  echo "Rofi se usará con el tema incluido por el perfil."
fi
