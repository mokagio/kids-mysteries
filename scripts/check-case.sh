#!/usr/bin/env bash

# Check a case file against the house rules in AGENTS.md.
# `content/mysteries/the-lighthouse-at-gull-point.md` predates those rules and is
# expected to fail.

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "usage: $0 <case.md> [case.md ...]" >&2
  exit 64
fi

status=0

fail() {
  echo "  ✗ $1"
  status=1
}

# Occurrences, not matching lines: a sentence can carry two `{{< word >}}` calls.
count() {
  { grep -o "$1" "$2" || true; } | wc -l | tr -d ' '
}

frontmatter() {
  awk 'NR > 1 && /^---$/ { exit } NR > 1 { print }' "$1"
}

clue_block() {
  awk '/^\{\{< clues >\}\}$/ { inside = 1; next } /^\{\{< \/clues >\}\}$/ { inside = 0 } inside' "$1"
}

for file in "$@"; do
  echo "$file"

  if [ ! -f "$file" ]; then
    fail "no such file"
    continue
  fi

  fm=$(frontmatter "$file")

  for key in title date setting difficulty; do
    grep -q "^${key}:" <<<"$fm" || fail "front matter is missing \`${key}:\`"
  done

  subjects=$(grep -c '^\(victim\|missing\):' <<<"$fm" || true)
  [ "$subjects" -eq 1 ] || fail "front matter needs exactly one of \`victim:\` or \`missing:\` (found $subjects)"

  difficulty=$(sed -n 's/^difficulty: *\([0-9]\).*/\1/p' <<<"$fm")
  case "$difficulty" in
    1 | 2 | 3) ;;
    *) fail "difficulty must be 1, 2 or 3 (found '${difficulty:-none}')" ;;
  esac

  suspects=$(count '{{< suspect ' "$file")
  [ "$suspects" -eq 3 ] || fail "needs exactly 3 suspects (found $suspects)"

  emojis=$(count '{{< suspect [^}]*emoji="' "$file")
  [ "$emojis" -eq "$suspects" ] || fail "every suspect needs an emoji ($emojis of $suspects have one)"

  clues=$(clue_block "$file" | grep -c '^[0-9]\+\. ' || true)
  [ "$clues" -eq 5 ] || fail "needs exactly 5 clues (found $clues)"

  words=$(count '{{< word ' "$file")
  [ "$words" -le 3 ] || fail "at most 3 advanced words (found $words)"

  defined=$(count '{{< word def="' "$file")
  [ "$defined" -eq "$words" ] || fail "every advanced word needs def=\" ($defined of $words have one)"

  grep -q '{{< solution culprit="' "$file" || fail "solution shortcode needs culprit=\""

  [ "$status" -eq 0 ] && echo "  ✓ house rules"
done

exit "$status"
