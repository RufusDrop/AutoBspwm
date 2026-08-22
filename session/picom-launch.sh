#!/usr/bin/env sh
set -u

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/autobspwm"
log_file="$cache_dir/picom.log"
install -d "$cache_dir"
: >"$log_file"

pkill -x picom >/dev/null 2>&1 || true
picom --config "${XDG_CONFIG_HOME:?}/picom/picom.conf" >>"$log_file" 2>&1 &
