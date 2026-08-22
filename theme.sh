#!/usr/bin/env bash
# Install a profile privately. It is loaded only by the AutoBspwm X session.
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "Ejecuta theme.sh con tu usuario normal, sin sudo." >&2
  exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# Management data always lives below the real home configuration directory.
# This remains correct even when the command is run from inside AutoBspwm,
# where XDG_CONFIG_HOME already points at the active profile.
config_home="$HOME/.config"
autobspwm_dir="$config_home/autobspwm"
themes=(Pacman Parrot S4vi Cinnamoroll Pink ZLCube Legion Kazerg Zeneapp Matterhorn Nord)
p10k_dir="$HOME/.local/share/autobspwm/powerlevel10k-1.20.18-58e13d1"

if [[ ! -r "$p10k_dir/powerlevel10k.zsh-theme" ]]; then
  echo "Falta Powerlevel10k privado. Ejecuta ./install.sh antes de cambiar de perfil." >&2
  exit 1
fi

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
  if command -v rofi >/dev/null 2>&1 && [[ -n ${DISPLAY:-} ]]; then
    # Ignore the user's global Rofi configuration here. A broken third-party
    # .rasi must never prevent selecting the actual AutoBspwm profile.
    printf '%s\n' "${themes[@]}" | rofi -no-config -dmenu -i \
      -p 'Perfil AutoBspwm' \
      -mesg 'El perfil elegido configura BSPWM, Polybar, Kitty, Rofi y el prompt'
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

# Convert every legacy ~/.config path to the selected profile's real absolute
# path. Polybar references require the documented ${env:VAR:fallback} form;
# baking the profile path avoids malformed interpolation and is unambiguous.
escaped_profile_dir="$(printf '%s' "$profile_dir" | sed 's/[&|\\]/\\&/g')"
while IFS= read -r -d '' file; do
  case "$file" in
    */bspwm/bspwmrc|*/bin/*|*/sxhkd/sxhkdrc|*/polybar/launch.sh|*/polybar/scripts/*|*/rofi/*)
      sed -i \
        -e "s|~/.config/|$escaped_profile_dir/|g" \
        -e "s|\$HOME/.config/|$escaped_profile_dir/|g" "$file"
      ;;
    *.ini|*/polybar/config)
      sed -i \
        -e "s|~/.config/|$escaped_profile_dir/|g" \
        -e "s|\$HOME/.config/|$escaped_profile_dir/|g" "$file"
      ;;
  esac
done < <(find "$profile_dir" -type f -not -path '*/fonts/*' -print0)

# Replace the 2023 compositor and launcher files with configurations tested
# against the current command-line/API. The launcher records Polybar failures
# instead of silently losing every process in the background.
install -Dm755 "$repo_dir/session/polybar-launch.sh" "$profile_dir/polybar/launch.sh"
install -Dm644 "$repo_dir/session/picom.conf" "$profile_dir/picom/picom.conf"
install -Dm755 "$repo_dir/session/picom-launch.sh" "$profile_dir/bin/picom-launch.sh"

# open-vm-tools exposes vmware-user, not the obsolete suid wrapper.
bspwmrc="$profile_dir/bspwm/bspwmrc"
if [[ -f "$bspwmrc" ]]; then
  sed -i 's|^[[:space:]]*vmware-user-suid-wrapper[[:space:]]*\&[[:space:]]*$|command -v vmware-user >/dev/null 2>\&1 \&\& vmware-user \&|' "$bspwmrc"
  sed -i "s|^[[:space:]]*picom[[:space:]]*\&[[:space:]]*$|$escaped_profile_dir/bin/picom-launch.sh|" "$bspwmrc"
  cat >>"$bspwmrc" <<'EOF'

# Kept outside individual profiles, so a profile switch preserves the layout.
[ -r "$HOME/.config/autobspwm/local.sh" ] && . "$HOME/.config/autobspwm/local.sh"
EOF
fi

# These files are visible only while the AutoBspwm session sets XDG_CONFIG_HOME
# and ZDOTDIR. The normal Kali desktop continues to use its own terminal setup.
case "$profile" in
  Nord)
    bg='#2E3440'; bg_alt='#3B4252'; fg='#ECEFF4'; accent='#88C0D0'
    blue='#81A1C1'; cyan='#8FBCBB'; green='#A3BE8C'; red='#BF616A'; yellow='#EBCB8B'; magenta='#B48EAD'
    ;;
  Matterhorn)
    bg='#0B1120'; bg_alt='#14213A'; fg='#D9E7FF'; accent='#62A0EA'
    blue='#5E9EFF'; cyan='#67D4E7'; green='#75D6A5'; red='#F07178'; yellow='#E6C177'; magenta='#91A7FF'
    ;;
  *)
    bg='#15111F'; bg_alt='#241C34'; fg='#E8E4F2'; accent='#A486DD'
    blue='#7AA2F7'; cyan='#7DCFFF'; green='#73DACA'; red='#F7768E'; yellow='#E0AF68'; magenta='#BB9AF7'
    ;;
esac

install -d "$profile_dir/kitty" "$profile_dir/zsh" "$profile_dir/rofi"
cat >"$profile_dir/kitty/kitty.conf" <<EOF
shell /usr/bin/zsh
font_family Iosevka Nerd Font
font_size 12
enable_audio_bell no
confirm_os_window_close 0
window_padding_width 12
background_opacity 0.88
dynamic_background_opacity yes
foreground $fg
background $bg
selection_foreground $bg
selection_background $accent
cursor $accent
cursor_text_color $bg
color0 $bg_alt
color1 $red
color2 $green
color3 $yellow
color4 $blue
color5 $magenta
color6 $cyan
color7 $fg
color8 $bg_alt
color9 $red
color10 $green
color11 $yellow
color12 $blue
color13 $magenta
color14 $cyan
color15 $fg
EOF
cat >"$profile_dir/zsh/.zshrc" <<'EOF'
# Reuse Kali's aliases, completion and history policy without modifying it.
[[ -r "$HOME/.zshrc" ]] && source "$HOME/.zshrc"
: ${HISTFILE:=$HOME/.zsh_history}
: ${HISTSIZE:=10000}
: ${SAVEHIST:=10000}
setopt append_history share_history hist_ignore_dups
(( $+aliases[ll] )) || alias ll='ls -lah --color=auto'

typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
source "$HOME/.local/share/autobspwm/powerlevel10k-1.20.18-58e13d1/powerlevel10k.zsh-theme"
[[ -r "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"
[[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
EOF

# Rofi 2 reads config.rasi. This self-contained theme defines every referenced
# colour and replaces the invalid legacy `rofi.theme:` configuration.
cat >"$profile_dir/rofi/config.rasi" <<EOF
configuration {
  modi: "drun,run,window";
  show-icons: true;
  font: "Iosevka Nerd Font 11";
  drun-display-format: "{icon} {name}";
}
* {
  bg: $bg;
  bg-alt: $bg_alt;
  fg: $fg;
  accent: $accent;
}
window {
  width: 42%;
  background-color: @bg;
  border: 2px;
  border-color: @accent;
  border-radius: 10px;
}
mainbox { background-color: transparent; padding: 12px; spacing: 8px; }
inputbar { background-color: @bg-alt; text-color: @fg; padding: 10px; border-radius: 7px; children: [prompt, entry]; }
prompt { background-color: transparent; text-color: @accent; padding: 0 8px 0 0; }
entry { background-color: transparent; text-color: @fg; }
listview { background-color: transparent; lines: 10; columns: 1; spacing: 4px; }
element { background-color: transparent; text-color: @fg; padding: 8px; border-radius: 6px; }
element selected { background-color: @bg-alt; text-color: @accent; }
element-icon { background-color: transparent; size: 1.5em; margin: 0 10px 0 0; }
element-text { background-color: transparent; text-color: inherit; }
EOF
rofi -no-config -rasi-validate "$profile_dir/rofi/config.rasi" >/dev/null
if [[ -f "$repo_dir/Themes/$profile/.p10k.zsh" ]]; then
  cp -a "$repo_dir/Themes/$profile/.p10k.zsh" "$profile_dir/zsh/.p10k.zsh"
elif [[ -f "$repo_dir/Themes/ZLCube/.p10k.zsh" ]]; then
  cp -a "$repo_dir/Themes/ZLCube/.p10k.zsh" "$profile_dir/zsh/.p10k.zsh"
fi
case "$profile" in
  Nord) p10k_accent=110 ;;
  Matterhorn) p10k_accent=75 ;;
  *) p10k_accent= ;;
esac
if [[ -n $p10k_accent && -f "$profile_dir/zsh/.p10k.zsh" ]]; then
  sed -i -E \
    -e "s|^(  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND)=013$|\1=$p10k_accent|" \
    -e "s|^(  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND)=013$|\1=$p10k_accent|" \
    -e "s|^(  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND)=013$|\1=$p10k_accent|" \
    "$profile_dir/zsh/.p10k.zsh"
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

# Store only the validated profile name. A plain pointer file is more reliable
# than replacing a directory symlink repeatedly and is easy to audit.
printf '%s\n' "$profile" >"$autobspwm_dir/.active-profile.new"
mv -f -- "$autobspwm_dir/.active-profile.new" "$autobspwm_dir/active-profile"
find "$profile_dir/bspwm" -type f -name 'bspwmrc' -exec chmod 700 {} + 2>/dev/null || true
find "$profile_dir/bspwm/scripts" -type f -exec chmod 700 {} + 2>/dev/null || true
find "$profile_dir/bin" -type f -name '*.sh' -exec chmod 700 {} + 2>/dev/null || true
find "$profile_dir/polybar" -type f -name '*.sh' -exec chmod 700 {} + 2>/dev/null || true

echo "Perfil $profile instalado en $profile_dir"
echo "En LightDM elige la sesión 'AutoBspwm', no la entrada BSPWM genérica."
echo "Rofi, Polybar, Kitty, Picom y Powerlevel10k usarán el perfil $profile."
