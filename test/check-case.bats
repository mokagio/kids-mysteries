#!/usr/bin/env bats

setup() {
  REPO="$BATS_TEST_DIRNAME/.."
  CHECK="$REPO/scripts/check-case.sh"
  CASE="$BATS_TEST_TMPDIR/case.md"
  cp "$REPO/content/mysteries/who-ate-the-cake.md" "$CASE"
}

@test "a case that follows the house rules passes" {
  run "$CHECK" "$CASE"
  [ "$status" -eq 0 ]
}

@test "the pre-house-rules case still fails" {
  run "$CHECK" "$REPO/content/mysteries/the-lighthouse-at-gull-point.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"exactly 3 suspects"* ]]
  [[ "$output" == *"exactly 5 clues"* ]]
}

@test "a fourth suspect is rejected" {
  cat >>"$CASE" <<'EOF'
{{< suspect name="Extra Person" role="The Spare" emoji="🧍" >}}
"One too many."
{{< /suspect >}}
EOF
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"exactly 3 suspects (found 4)"* ]]
}

@test "a sixth clue is rejected" {
  perl -0pi -e 's/(\{\{< \/clues >\}\})/6. One clue too many.\n\n$1/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"exactly 5 clues (found 6)"* ]]
}

@test "numbered lines outside the clues block are not counted as clues" {
  printf '\n1. A numbered line in the prose.\n' >>"$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 0 ]
}

@test "a suspect without an emoji is rejected" {
  perl -pi -e 's/ emoji="🧹"//' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"every suspect needs an emoji"* ]]
}

@test "a fourth advanced word is rejected" {
  perl -0pi -e 's/(\{\{< \/solution >\}\})/A fourth {{< word def="too many" >}}word{{< \/word >}}.\n\n$1/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"at most 3 advanced words (found 4)"* ]]
}

@test "an advanced word without a definition is rejected" {
  perl -pi -e 's/\{\{< word def="the person who did it" >\}\}/{{< word >}}/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"every advanced word needs def"* ]]
}

@test "a solution without a culprit is rejected" {
  perl -pi -e 's/\{\{< solution culprit="Coach Tibbs" >\}\}/{{< solution >}}/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"culprit"* ]]
}

@test "both victim and missing is rejected" {
  perl -pi -e 's/^missing: (.*)$/missing: $1\nvictim: Someone/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"exactly one of"* ]]
}

@test "none of victim, missing or incident is rejected" {
  perl -ni -e 'print unless /^missing:/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"exactly one of"* ]]
}

@test "incident alone is accepted" {
  perl -pi -e 's/^missing: .*$/incident: Something was let loose/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 0 ]
}

@test "victim alone is accepted" {
  perl -pi -e 's/^missing: .*$/victim: Someone Nobody Knows/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 0 ]
}

@test "a difficulty outside 1-3 is rejected" {
  perl -pi -e 's/^difficulty: 1$/difficulty: 4/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"difficulty must be 1, 2 or 3"* ]]
}

@test "a missing front matter key is reported" {
  perl -ni -e 'print unless /^setting:/' "$CASE"
  run "$CHECK" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"missing \`setting:\`"* ]]
}

@test "a passing file is still marked passing after a failing one" {
  run "$CHECK" "$REPO/content/mysteries/the-lighthouse-at-gull-point.md" "$CASE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"✓ house rules"* ]]
}

@test "a file that does not exist is reported" {
  run "$CHECK" "$BATS_TEST_TMPDIR/nope.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no such file"* ]]
}

@test "no arguments prints usage" {
  run "$CHECK"
  [ "$status" -eq 64 ]
  [[ "$output" == *"usage:"* ]]
}
