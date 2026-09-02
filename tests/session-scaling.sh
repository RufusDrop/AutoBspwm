#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
session="$repo_dir/session/autobspwm-session"

grep -F 'AUTOBSPWM_DPI="${AUTOBSPWM_DPI:-96}"' "$session" >/dev/null
grep -F 'AUTOBSPWM_CURSOR_SIZE="${AUTOBSPWM_CURSOR_SIZE:-24}"' "$session" >/dev/null
grep -F 'export XCURSOR_SIZE="$AUTOBSPWM_CURSOR_SIZE"' "$session" >/dev/null
grep -F "printf 'Xft.dpi: %s\\nXcursor.size: %s\\n'" "$session" >/dev/null
grep -F 'xrdb -load "$xresources_backup"' "$session" >/dev/null

echo 'session scaling test: OK'
