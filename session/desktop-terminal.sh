#!/usr/bin/env bash
set -euo pipefail

desktop_dir="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
[[ -n $desktop_dir && -d $desktop_dir ]] || desktop_dir="$HOME/Desktop"
[[ -d $desktop_dir ]] || desktop_dir="$HOME"
exec /usr/bin/kitty --directory "$desktop_dir"
