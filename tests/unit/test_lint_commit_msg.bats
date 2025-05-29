#!/usr/bin/env bats

load '/usr/lib/bats/bats-support/load'
load '/usr/lib/bats/bats-assert/load'

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  LINT_COMMIT_MSG_SCRIPT="$TEST_DIR/../../lint-commit-msg.sh"
}

lint_commit_msg() {
  # Run `lint-commit-msg.sh` at commit_msg stage mocking the specified arguments.
  #
  # Arguments:
  #   $1 - branch name
  #   $2 - commit message
  local branch_name="$1"
  local commit_msg="$2"

  local tmpfile
  tmpfile="$(mktemp)"
  echo "$commit_msg" > "$tmpfile"

  env MOCK_GIT_REV_PARSE="$branch_name" \
    PATH="$TEST_DIR/../mocks:$PATH" \
    "$BATS_SHELL" "$LINT_COMMIT_MSG_SCRIPT" "$tmpfile"

  local exit_code=$?
  rm -f "$tmpfile"
  return "$exit_code"
}

@test "Valid commit message matches branch" {
  run lint_commit_msg "abc-123-my-branch" "ABC-123 my message"
  assert_success
}

@test "Short ID is valid" {
  run lint_commit_msg "abc-1" "ABC-1"
  assert_success
}

@test "Long ID is valid" {
  run lint_commit_msg "abcd-1" "ABCD-1"
  assert_success
}

@test "Multiple IDs, including matching one, are valid" {
  run lint_commit_msg "abc-1" "ABC-2 ABC-1"
  assert_success
}

@test "Invalid multiple IDs, wrong reference first" {
  run lint_commit_msg "abc-1" "ABC-2 but also related to ABC-1"
  assert_failure
}

@test "Auto merge message is valid" {
  run lint_commit_msg "abc-123" "Merge branch 'abc-123-extra' int 'abc-123'"
  assert_success
}

@test "Mismatch merge message fails" {
  run lint_commit_msg "abc-123" "ABC-234 Merge branch 'abc-123-extra' int 'abc-123'"
  assert_failure
}

@test "Mismatch ID alpha in message fails" {
  run lint_commit_msg "abc-123-my-branch" "ABCD-123 my message"
  assert_failure
}

@test "Mismatch ID digits in message fails" {
  run lint_commit_msg "abc-123-my-branch" "ABC-12 my message"
  assert_failure
}

@test "Naive message without ID fails" {
  run lint_commit_msg "abc-123-my-branch" "my message"
  assert_failure
}

@test "Lowercase ID in message fails" {
  run lint_commit_msg "abc-123-my-branch" "abc-123 message"
  assert_failure
}
