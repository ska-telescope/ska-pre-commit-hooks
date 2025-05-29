#!/usr/bin/env bats

load '/usr/lib/bats/bats-support/load'
load '/usr/lib/bats/bats-assert/load'

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  LINT_COMMIT_MSG_SCRIPT="$TEST_DIR/../../lint-commit-msg.sh"
  export PRE_COMMIT_TO_REF=1
}

lint_pre_push() {
  # Run `lint-commit-msg.sh` at pre-push stage mocking the specified arguments.
  #
  # Arguments:
  #   $1 - branch name
  #   $2 - commit message
  local branch_name="$1"
  local commit_id="$2"
  local commit_msg="$3"

  env MOCK_GIT_REV_PARSE="$branch_name" \
      MOCK_GIT_LOG="$commit_id $commit_msg" \
      PATH="$TEST_DIR/../mocks:$PATH" \
      "$BATS_SHELL" "$LINT_COMMIT_MSG_SCRIPT"
}

@test "git rev-parse and log is mocked" {
  local branch_name="mock-branch"
  local commit_id="123"
  local commit_msg="msg"

  run env MOCK_GIT_REV_PARSE="$branch_name" \
      MOCK_GIT_LOG="$commit_id $commit_msg" \
      PATH="$TEST_DIR/../mocks:$PATH" \
      git rev-parse --abbrev-ref HEAD
  assert_equal "$output" "$branch_name"

  run env MOCK_GIT_REV_PARSE="$branch_name" \
      MOCK_GIT_LOG="$commit_id $commit_msg" \
      PATH="$TEST_DIR/../mocks:$PATH" \
      git log --format="%h %s"
  assert_equal "$output" "$commit_id $commit_msg"
}

@test "Valid commit message matches branch" {
  run lint_pre_push "abc-123-my-branch" "123456" "ABC-123 my message"
  assert_success
}

@test "Short ID is valid" {
  run lint_pre_push "abc-1" "123456" "ABC-1"
  assert_success
}

@test "Long ID is valid" {
  run lint_pre_push "abcd-1" "123456" "ABCD-1"
  assert_success
}

@test "Multiple IDs, including matching one, are valid" {
  run lint_pre_push "abc-1" "123456" "ABC-2 ABC-1"
  assert_success
}

@test "Invalid multiple IDs, wrong one first" {
  run lint_pre_push "abc-1" "123456" "ABC-2 but also related to ABC-1"
  assert_failure
}

@test "Invalid uppercase branch name" {
  run lint_pre_push "ABC-1" "123456" "ABC-1 message"
  assert_failure
}

@test "Auto merge message is valid" {
  run lint_pre_push "abc-123" "123456" "Merge branch 'abc-123-extra' int 'abc-123'"
  assert_success
}

@test "Mismatch merge message fails" {
  run lint_pre_push "abc-123" "123456" "ABC-234 Merge branch 'abc-123-extra' int 'abc-123'"
  assert_failure
}

@test "Mismatch ID alpha in message fails" {
  run lint_pre_push "abc-123-my-branch" "123456" "ABCD-123 my message"
  assert_failure
}

@test "Mismatch ID digits in message fails" {
  run lint_pre_push "abc-123-my-branch" "123456" "ABC-12 my message"
  assert_failure
}

@test "Naive message with no ID fails" {
  run lint_pre_push "abc-123-my-branch" "123456" "my message"
  assert_failure
}

@test "Lowercase ID in message fails" {
  run lint_pre_push "abc-123-my-branch" "123456" "abc-123 message"
  assert_failure
}
