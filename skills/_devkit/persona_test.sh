#!/usr/bin/env bash
# Tests for the persona script. Usage: persona_test.sh  (exits non-zero on the first failure)
set -u
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'trash "$tmp" 2>/dev/null || rmdir "$tmp" 2>/dev/null' EXIT
export PERSONAS_FILE="$tmp/personas.jsonl"
p() { python3 -I "$here/persona" "$@"; }
fail() { echo "FAIL: $*"; exit 1; }
ok() { echo "ok: $*"; }

cat > "$PERSONAS_FILE" <<'JSONL'
{"name": "Codebase Explorer", "kind": "task", "statement": "You are a codebase explorer. Your only job is to find symbols.", "deliverable": "file:line list"}
{"name": "Saboteur", "kind": "lens", "statement": "You are the Saboteur. Your only job is to break this change.", "deliverable": "findings"}
{"name": "One Shot", "kind": "one-off", "statement": "You are a one shot. Your only job is to explore once.", "deliverable": "x", "notes": "load /voice"}
JSONL

p lint >/dev/null || fail "lint on valid file"; ok "lint passes valid file"
[ "$(p find explorer | cut -f1)" = "Codebase Explorer" ] || fail "find by name"; ok "find by name"
p find saboteur >/dev/null 2>&1 && fail "find returned a lens without --all"; ok "find hides lens rows"
p find --all saboteur | grep -q Saboteur || fail "find --all"; ok "find --all includes lens rows"
p find --all "one shot" | grep -q "load /voice" || fail "notes column"; ok "find prints notes"
p find zzzzqq >/dev/null 2>&1 && fail "no-match exit"; ok "find exits 1 on no match"

p add "Log Reader" "You are a log reader. Your only job is to read logs." "summary" >/dev/null || fail "add valid"
[ "$(wc -l < "$PERSONAS_FILE" | tr -d ' ')" = 4 ] || fail "add appended one line"; ok "add appends one line"
p add "log reader" "You are a log reader. Your only job is to read logs." "summary" >/dev/null 2>&1 && fail "dup accepted"; ok "add rejects duplicate name"
p add "Bad" "no job phrase here" "x" >/dev/null 2>&1 && fail "bad statement accepted"; ok "add rejects statement without job phrase"
p add "Inject" $'You are x. Your only job is y.\n{"name": "Forged"}' "x" >/dev/null 2>&1 && fail "newline accepted"; ok "add rejects line breaks"
p add --kind bogus "K" "You are k. Your only job is k." "x" >/dev/null 2>&1 && fail "bad kind accepted"; ok "add rejects unknown kind"
p add "Sep" $'You are s. Your only job is s. more' "x" >/dev/null 2>&1 && fail "U+2028 accepted"; ok "add rejects unicode line separators"
p lint >/dev/null || fail "lint after rejected adds"; ok "file still lints after rejected adds"
grep -q Forged "$PERSONAS_FILE" && fail "forged row persisted"; ok "no forged rows"

echo '{"name": "Broken"' >> "$PERSONAS_FILE"
p lint >/dev/null && fail "lint passed broken JSON"; ok "lint flags invalid JSON"
p add "After" "You are a. Your only job is a." "x" >/dev/null 2>&1 && fail "add on broken file"; ok "add refuses an invalid file"
echo "all persona tests passed"
