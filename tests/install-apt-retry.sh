#!/usr/bin/env bash
# Verify that dependency download failures are retried without reaching themes.
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home"
export AUTOBSPWM_APT_TEST_LOG="$test_dir/apt.log"

cat >"$test_dir/bin/sudo" <<'EOF'
#!/usr/bin/env bash
case " $* " in
  *" apt-get "*" update "*) printf 'update\n' >>"$AUTOBSPWM_APT_TEST_LOG"; exit 0 ;;
  *" apt-get "*" install "*) printf 'install\n' >>"$AUTOBSPWM_APT_TEST_LOG"; exit 100 ;;
  *" apt-get clean "*) printf 'clean\n' >>"$AUTOBSPWM_APT_TEST_LOG"; exit 0 ;;
esac
printf 'unexpected sudo call: %s\n' "$*" >&2
exit 99
EOF
chmod +x "$test_dir/bin/sudo"

if HOME="$test_dir/home" PATH="$test_dir/bin:$PATH" "$repo_dir/install.sh" \
    >"$test_dir/output.log" 2>&1; then
  echo "install.sh debía fallar tras agotar los reintentos de APT" >&2
  exit 1
fi

[[ $(grep -c '^install$' "$AUTOBSPWM_APT_TEST_LOG") -eq 3 ]]
[[ $(grep -c '^update$' "$AUTOBSPWM_APT_TEST_LOG") -eq 3 ]]
[[ $(grep -c '^clean$' "$AUTOBSPWM_APT_TEST_LOG") -eq 2 ]]
grep -q 'No se ha aplicado ningún perfil de AutoBspwm' "$test_dir/output.log"
