#!/usr/bin/env bash
set -Eeuo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
trap 'printf "nsh test failed at line %s\n" "$LINENO" >&2' ERR

export NSH_HOME="$fixture/.nsh" PATH="$fixture/bin:$repo/bin:$PATH"
export CALL_LOG="$fixture/agents"
mkdir -p -- "$fixture/bin" "$fixture/work tree"
cd -- "$fixture"

cat > "$fixture/bin/law" <<'EOF'
#!/usr/bin/env bash
set -eu
test "${NSH_TURN:-}" = 1
test "$1" = @@
test "$2" = --
printf 'law: %s\n' "$3" >> "$CALL_LOG"
context=$(cat)
[[ "$context" == *"NSH_HOME: $NSH_HOME"* ]]
case "$3" in
    'mystery @cbh')
        [[ "$context" == *'Bash result: exit 127'*'mystery: command not found'* ]]
        [[ "$context" == *'Input: cd "work tree"'*'Input: false'*'Status: 1'* ]]
        printf '@more\n'
        ;;
    fg)
        [[ "$context" == *'Pending question:'*'What should mystery do?'*'Input: mystery @cbh'* ]]
        printf '%s\n' '@cbh | mystery means say lite' > "$NSH_HOME/etc/nshrc"
        printf '%s\n' "alias speak='echo alias'" > "$NSH_HOME/etc/nsh.bash"
        printf '%s\n' '#!/bin/sh' 'echo lite' > "$NSH_HOME/bin/mystery"
        chmod +x -- "$NSH_HOME/bin/mystery"
        printf 'Learned.\n'
        ;;
    $'take note:\n  keep this line')
        printf 'Got both lines.\n'
        ;;
    '@cbh recall mystery')
        [[ "$context" == *'Saved scope definitions'*'@cbh | mystery means say lite'* ]]
        printf 'mystery means say lite\n'
        ;;
    "cat 'this prompt' @ sed 's/write a prompt/do this prompt/'")
        [[ "$context" == *'Bash result: not run'* ]]
        sed 's/write a prompt/do this prompt/' 'this prompt'
        ;;
    *)
        printf 'unexpected agent call: %s\n' "$3" >&2
        exit 70
        ;;
esac
EOF
cat > "$fixture/bin/lawd" <<'EOF'
#!/usr/bin/env bash
set -eu
test "$3" = 'mystery @cbh'
cat > /dev/null
printf 'lawd: %s\n' "$3" >> "$CALL_LOG"
printf '@ask\nWhat should mystery do?\n'
EOF
chmod +x -- "$fixture/bin/"*

nsh > "$fixture/output" 2> "$fixture/stderr" <<'EOF'
cd "work tree"
light=42
printf 'native %s\n' "$light"
false
echo $?
mystery @cbh
ld.so printf 'question status %s\n' "$?"
fg
speak
mystery
EOF
printf '%s\n' 'native 42' 1 'question status 2' Learned. alias lite > "$fixture/expected"
cmp "$fixture/expected" "$fixture/output"
printf '%s\n' 'What should mystery do?' > "$fixture/expected"
cmp "$fixture/expected" "$fixture/stderr"
printf '%s\n' 'law: mystery @cbh' 'lawd: mystery @cbh' 'law: fg' > "$fixture/expected"
cmp "$fixture/expected" "$CALL_LOG"

nsh -c 'speak; mystery' > "$fixture/output"
printf '%s\n' alias lite > "$fixture/expected"
cmp "$fixture/expected" "$fixture/output"
test "$(cat "$NSH_HOME/etc/nshrc")" = '@cbh | mystery means say lite'
nsh -c '@cbh recall mystery' > "$fixture/output"
test "$(cat "$fixture/output")" = 'mystery means say lite'

@ -c 'printf "%s %s\n" "$0" "$1"' script argument > "$fixture/output"
test "$(cat "$fixture/output")" = 'script argument'

printf '%s\n' 'write a prompt' > 'this prompt'
@ -c "cat 'this prompt' @ sed 's/write a prompt/do this prompt/'" > "$fixture/output"
test "$(cat "$fixture/output")" = 'do this prompt'
@ -c 'echo "quoted @ text"; echo \@ native' > "$fixture/output"
printf '%s\n' 'quoted @ text' '@ native' > "$fixture/expected"
cmp "$fixture/expected" "$fixture/output"
@ -c 'ld.so echo native @ escape' > "$fixture/output"
test "$(cat "$fixture/output")" = 'native @ escape'

printf '%s\n' 'take note:' '  keep this line' '' | nhs > "$fixture/output"
test "$(cat "$fixture/output")" = 'Got both lines.'
