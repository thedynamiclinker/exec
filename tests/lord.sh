#!/usr/bin/env bash
set -Eeuo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
fixture="$(mktemp -d)"
trap 'rm -rf -- "$fixture"' EXIT
trap 'printf "lord test failed at line %s\n" "$LINENO" >&2' ERR

export EXEC="$repo" HOME="$fixture/home" PATH="$fixture/bin:$repo/bin:$PATH"
export CALL_ARGS="$fixture/args" CALL_STDIN="$fixture/stdin"
unset LORD_PROFILE
mkdir -p -- "$HOME" "$fixture/bin" "$fixture/worktree"
printf '%s\n' 'echo unexpected startup banner' > "$HOME/.bashrc"

cat > "$fixture/bin/codex" <<'EOF'
#!/usr/bin/env bash
printf '%s\0' "$@" > "$CALL_ARGS"
cat > "$CALL_STDIN"
printf '%s' "${CODEX_OUTPUT-$'mù\n'}"
printf '%s\n' 'backend diagnostic' >&2
exit "${CODEX_STATUS:-0}"
EOF
chmod +x -- "$fixture/bin/codex"

cd -- "$fixture/worktree"
git init -q
ln -s -- "$repo/etc/lord/AGENTS-repo.md" AGENTS.md
mkdir -- .lord-agents.lock
touch -- would-expand

printf 'mù\n' > "$fixture/expected"
law echo 木 @ pinyin </dev/null > "$fixture/output" 2> "$fixture/stderr"
cmp "$fixture/expected" "$fixture/output"
cmp "$fixture/expected" "$HOME/.cache/lord/"*
test ! -s "$fixture/stderr"
test "$(readlink -- AGENTS.md)" = "$repo/etc/lord/AGENTS-repo.md"
test -d .lord-agents.lock
mapfile -d '' -t args < "$CALL_ARGS"
test "${args[0]}" = exec
test "${args[1]}" = -c
test "${args[2]}" = 'model_reasoning_effort="low"'
test "${args[3]}" = --model=gpt-6-luna
[[ "${args[*]}" == *'developer_instructions='*'Hanyu Pinyin'*'tone marks by default'* ]]
test "${args[-2]}" = --
[[ "${args[-1]}" == *$'\necho 木\n@\npinyin' ]]

printf '木\n' > "$fixture/input"
lord @unix pinyin @ uppercase @ 'append *' < "$fixture/input" > "$fixture/output"
cmp "$fixture/input" "$CALL_STDIN"
mapfile -d '' -t args < "$CALL_ARGS"
[[ "${args[-1]}" == *$'\npinyin\n@\nuppercase\n@\nappend *' ]]

CODEX_OUTPUT=$'mù\n\n' @ 'pinyin *' < "$fixture/input" > "$fixture/output"
printf 'mù\n\n' > "$fixture/expected"
cmp "$fixture/expected" "$fixture/output"
mapfile -d '' -t args < "$CALL_ARGS"
test "${args[-1]}" = 'pinyin *'

lord @echo @repo @color=never -- echo @ pinyin > "$fixture/output"
[[ "$(cat "$fixture/output")" == *'--color=never'*'echo\ @\ pinyin' ]]

for pipeline in 'echo @' 'echo @ @ pinyin' '@ pinyin'; do
    read -r -a words <<< "$pipeline"
    status=0
    law "${words[@]}" > "$fixture/output" 2> "$fixture/stderr" || status=$?
    test "$status" = 2
    test ! -s "$fixture/output"
    grep -q 'expected a stage' "$fixture/stderr"
done

status=0
CODEX_STATUS=42 law echo 木 @ pinyin </dev/null > "$fixture/output" 2> "$fixture/stderr" || status=$?
test "$status" = 42
test ! -s "$fixture/output"
grep -qx 'backend diagnostic' "$fixture/stderr"
