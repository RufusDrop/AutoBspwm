#!/usr/bin/env bash
# Installs Kali/Debian packages and a pinned, user-local Powerlevel10k release.
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "Ejecuta install.sh con tu usuario normal, sin sudo." >&2
  exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
packages=(
  bspwm sxhkd polybar picom rofi feh dunst kitty git lsd bat binutils
  fontforge-nox python3-fontforge i3lock
  x11-xserver-utils x11-xkb-utils xclip xdotool scrot wmname acpi imagemagick
  open-vm-tools-desktop zsh zsh-autosuggestions zsh-syntax-highlighting
  fonts-noto-color-emoji fonts-font-awesome
)

echo "Actualizando el índice de paquetes…"
sudo apt update
echo "Instalando BSPWM, Polybar y dependencias desde los repositorios de Kali…"
sudo apt install -y "${packages[@]}"

# An unclean VMware shutdown can leave NUL bytes in .zsh_history. Recover the
# readable commands after APT has made zsh available, retaining the original
# file with a timestamp instead of silently discarding history.
bash "$repo_dir/session/repair-zsh-history.sh"

# Kali rolling does not always publish zsh-theme-powerlevel10k. Keep a pinned
# copy below ~/.local so the AutoBspwm prompt does not depend on that package
# and the normal Kali session never loads it implicitly.
p10k_revision=58e13d16a50e1d6908e39e20a670896808ccf350
p10k_label=1.20.18-58e13d1
p10k_dir="$HOME/.local/share/autobspwm/powerlevel10k-$p10k_label"
if [[ ! -r "$p10k_dir/powerlevel10k.zsh-theme" ]]; then
  if [[ -e "$p10k_dir" ]]; then
    echo "La instalación privada de Powerlevel10k está incompleta: $p10k_dir" >&2
    echo "Muévela o elimínala y vuelve a ejecutar el instalador." >&2
    exit 1
  fi
  p10k_parent="$(dirname -- "$p10k_dir")"
  install -d "$p10k_parent"
  echo "Instalando Powerlevel10k $p10k_label solo para AutoBspwm…"
  p10k_tmp="$(mktemp -d "$p10k_parent/.powerlevel10k.XXXXXXXX")"
  cleanup_p10k() { rm -rf -- "$p10k_tmp"; }
  trap cleanup_p10k EXIT
  git -C "$p10k_tmp" init -q
  git -C "$p10k_tmp" remote add origin https://github.com/romkatv/powerlevel10k.git
  git -C "$p10k_tmp" fetch -q --depth 1 origin "$p10k_revision"
  git -C "$p10k_tmp" checkout -q --detach FETCH_HEAD
  [[ $(git -C "$p10k_tmp" rev-parse HEAD) == "$p10k_revision" ]]
  mv -- "$p10k_tmp" "$p10k_dir"
  trap - EXIT
fi

# A dedicated X session is the isolation boundary: Kali default never reads a
# profile's Picom, Polybar, Kitty or Zsh configuration.
sudo install -Dm755 "$repo_dir/session/autobspwm-session" /usr/local/bin/autobspwm-session
sudo install -Dm644 "$repo_dir/session/autobspwm.desktop" /usr/share/xsessions/autobspwm.desktop

# Do not write Rofi, sxhkd, Kitty or Zsh configuration into ~/.config. Those
# files belong to Kali's default desktop. Profiles receive private copies.
font_dir="$HOME/.local/share/fonts/AutoBspwm"
install -d "$font_dir"

# Polybar profiles use these fonts. User-local installation needs no sudo.
find "$repo_dir/Themes" -path '*/polybar/fonts/*' -type f -print0 |
  xargs -0 -r -I{} install -m644 "{}" "$font_dir/"

# Build a one-glyph font from the supplied Matterhorn silhouette. Text widgets
# cannot display PNG files directly; an actual font preserves the exact shape
# in Polybar and Powerlevel10k.
mountain_font="$font_dir/AutoBspwmMountain.ttf"
font_log="${XDG_CACHE_HOME:-$HOME/.cache}/autobspwm/fontforge.log"
install -d "$(dirname -- "$font_log")"
if ! fontforge -lang=py -script "$repo_dir/scripts/generate-mountain-font.py" \
    "$repo_dir/assets/mountain.svg" "$mountain_font" >"$font_log" 2>&1; then
  echo "Aviso: no se pudo generar el icono Matterhorn; se usará el fallback ▲▴." >&2
  echo "Registro: $font_log" >&2
  rm -f -- "$mountain_font"
fi
fc-cache -f "$font_dir" >/dev/null

echo "Dependencias instaladas. Ahora selecciona el perfil que quieres aplicar."
exec "$repo_dir/theme.sh"
