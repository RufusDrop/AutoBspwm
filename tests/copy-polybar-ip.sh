#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
mkdir -p "$test_dir/profile/bin" "$test_dir/mock-bin"
export AUTOBSPWM_CLIPBOARD_TEST="$test_dir/clipboard"

cat >"$test_dir/profile/bin/ethernet_status.sh" <<'EOF'
#!/usr/bin/env bash
printf 'icon 192.168.75.132\n'
EOF
cat >"$test_dir/profile/bin/htb_status.sh" <<'EOF'
#!/usr/bin/env bash
printf 'VPN 10.10.14.23\n'
EOF
cat >"$test_dir/profile/bin/htb_target.sh" <<'EOF'
#!/usr/bin/env bash
printf 'target 10.10.11.42 - box\n'
EOF
cat >"$test_dir/mock-bin/xclip" <<'EOF'
#!/usr/bin/env bash
cat >"$AUTOBSPWM_CLIPBOARD_TEST"
EOF
chmod +x "$test_dir/profile/bin/"*.sh "$test_dir/mock-bin/xclip"

copy_ip() {
  XDG_CONFIG_HOME="$test_dir/profile" \
    PATH="$test_dir/mock-bin:$PATH" \
    "$repo_dir/session/copy-polybar-ip.sh" "$1"
}

copy_ip local
grep -Fx '192.168.75.132' "$AUTOBSPWM_CLIPBOARD_TEST" >/dev/null
copy_ip vpn
grep -Fx '10.10.14.23' "$AUTOBSPWM_CLIPBOARD_TEST" >/dev/null
copy_ip target
grep -Fx '10.10.11.42' "$AUTOBSPWM_CLIPBOARD_TEST" >/dev/null

echo 'copy Polybar IP test: OK'
