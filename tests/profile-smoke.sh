#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "profile smoke test skipped as root"
  exit 0
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
test_home="$(mktemp -d)"
trap 'rm -rf -- "$test_home"' EXIT

mkdir -p "$test_home/.local/share/autobspwm/powerlevel10k-1.20.18-58e13d1"
touch "$test_home/.local/share/autobspwm/powerlevel10k-1.20.18-58e13d1/powerlevel10k.zsh-theme"

for theme in Matterhorn Nord; do
  HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" \
    "$repo_dir/theme.sh" "$theme" >/dev/null
  profile="$test_home/.config/autobspwm/profiles/$theme"

  test -x "$profile/bspwm/bspwmrc"
  test -x "$profile/polybar/launch.sh"
  test -x "$profile/bin/picom-launch.sh"
  test -r "$profile/rofi/config.rasi"
  test -r "$profile/kitty/kitty.conf"
  grep -F "$profile/polybar/colors.ini" "$profile/polybar/current.ini" >/dev/null
  grep -F "$profile/bin/picom-launch.sh" "$profile/bspwm/bspwmrc" >/dev/null
  grep -F 'modules-center = my-text-label' "$profile/polybar/current.ini" >/dev/null
  grep -F '[module/my-text-label]' "$profile/polybar/current.ini" >/dev/null
  grep -F 'modules-center = mountain workspaces' "$profile/polybar/workspace.ini" >/dev/null
  grep -F '[module/mountain]' "$profile/polybar/workspace.ini" >/dev/null
  grep -F 'source "$HOME/.local/share/autobspwm/powerlevel10k-1.20.18-58e13d1/powerlevel10k.zsh-theme"' \
    "$profile/zsh/.zshrc" >/dev/null
  ! grep -R -E '~/.config/|\$\{env:XDG_CONFIG_HOME\}' \
    "$profile/bspwm" "$profile/bin" "$profile/polybar" "$profile/sxhkd" >/dev/null
  if [[ $theme == Nord ]]; then
    grep -F 'background #2E3440' "$profile/kitty/kitty.conf" >/dev/null
    grep -F 'POWERLEVEL9K_OS_ICON_BACKGROUND=110' "$profile/zsh/.p10k.zsh" >/dev/null
  else
    grep -F 'background #0B1120' "$profile/kitty/kitty.conf" >/dev/null
    grep -F 'POWERLEVEL9K_OS_ICON_BACKGROUND=75' "$profile/zsh/.p10k.zsh" >/dev/null
  fi
done

# Switching from inside an active session must still manage ~/.config/autobspwm.
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config/autobspwm/profiles/Matterhorn" \
  "$repo_dir/theme.sh" Nord >/dev/null
grep -Fx 'Nord' "$test_home/.config/autobspwm/active-profile" >/dev/null
echo "profile smoke test: OK"
