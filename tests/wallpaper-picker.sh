#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
mkdir -p "$test_dir/profile/Wallpaper" "$test_dir/bin" "$test_dir/state"
touch "$test_dir/profile/Wallpaper/a.jpg"
touch "$test_dir/profile/Wallpaper/b.png"
touch "$test_dir/profile/Wallpaper/c.webp"
printf '%s\n' 'b.png' >"$test_dir/profile/Wallpaper/.default"

cat >"$test_dir/bin/feh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${!#}" >>"$AUTOBSPWM_WALLPAPER_TEST_LOG"
EOF
chmod +x "$test_dir/bin/feh"
export AUTOBSPWM_WALLPAPER_TEST_LOG="$test_dir/feh.log"

run_picker() {
  HOME="$test_dir" XDG_CONFIG_HOME="$test_dir/profile" \
    XDG_STATE_HOME="$test_dir/state" PATH="$test_dir/bin:$PATH" \
    "$repo_dir/session/wallpaper-picker.sh" "$1"
}

run_picker startup
[[ $(tail -n1 "$AUTOBSPWM_WALLPAPER_TEST_LOG") == */b.png ]]
run_picker next
[[ $(tail -n1 "$AUTOBSPWM_WALLPAPER_TEST_LOG") == */c.webp ]]
run_picker next
[[ $(tail -n1 "$AUTOBSPWM_WALLPAPER_TEST_LOG") == */a.jpg ]]
run_picker previous
[[ $(tail -n1 "$AUTOBSPWM_WALLPAPER_TEST_LOG") == */c.webp ]]
grep -Fx "$test_dir/profile/Wallpaper/c.webp" \
  "$test_dir/state/autobspwm/wallpaper-profile" >/dev/null

echo "wallpaper picker test: OK"
