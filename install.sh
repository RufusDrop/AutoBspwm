#!/usr/bin/env bash
# Installs only Kali/Debian packages. No unpinned source builds are required.
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "Ejecuta install.sh con tu usuario normal, sin sudo." >&2
  exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
packages=(
  bspwm sxhkd polybar picom rofi feh dunst kitty zenity
  x11-xserver-utils x11-xkb-utils xclip xdotool scrot wmname acpi imagemagick
  open-vm-tools-desktop zsh zsh-autosuggestions zsh-syntax-highlighting
  fonts-noto-color-emoji fonts-font-awesome
)

echo "Actualizando el índice de paquetes…"
sudo apt update
if apt-cache show zsh-theme-powerlevel10k >/dev/null 2>&1; then
  packages+=(zsh-theme-powerlevel10k)
fi
echo "Instalando BSPWM, Polybar y dependencias desde los repositorios de Kali…"
sudo apt install -y "${packages[@]}"

# A dedicated X session is the isolation boundary: Kali default never reads a
# profile's Picom, Polybar, Kitty or Zsh configuration.
sudo install -Dm755 "$repo_dir/session/autobspwm-session" /usr/local/bin/autobspwm-session
sudo install -Dm644 "$repo_dir/session/autobspwm.desktop" /usr/share/xsessions/autobspwm.desktop

# Keep an existing shortcut configuration: it may contain user customizations.
if [[ ! -e "$HOME/.config/sxhkd/sxhkdrc" ]]; then
  install -Dm644 "$repo_dir/Config/sxhkd/sxhkdrc" "$HOME/.config/sxhkd/sxhkdrc"
fi

install -d "$HOME/.config/rofi/themes" "$HOME/.local/share/fonts/AutoBspwm"
if [[ -f "$repo_dir/rofi/nord.rasi" ]]; then
  install -m644 "$repo_dir/rofi/nord.rasi" "$HOME/.config/rofi/themes/nord.rasi"
fi

# Polybar profiles use these fonts. User-local installation needs no sudo.
find "$repo_dir/Themes" -path '*/polybar/fonts/*' -type f -print0 |
  xargs -0 -r -I{} install -m644 "{}" "$HOME/.local/share/fonts/AutoBspwm/"
fc-cache -f "$HOME/.local/share/fonts/AutoBspwm" >/dev/null

echo "Dependencias instaladas. Ahora selecciona el perfil que quieres aplicar."
exec "$repo_dir/theme.sh"
