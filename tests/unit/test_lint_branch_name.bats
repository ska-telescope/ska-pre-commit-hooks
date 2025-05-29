#!/usr/bin/env bats

load '/usr/lib/bats/bats-support/load'
load '/usr/lib/bats/bats-assert/load'

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  LINT_BRANCH_NAME_SCRIPT="$TEST_DIR/../../lint-branch-name.sh"
}

lint_branch_name() {
  # Run `lint-branch-name.sh` mocking the specified arguments.
  #
  # Arguments:
  #   $1 - branch name
  local branch_name="$1"

  # Make sure $TEST_DIR and $LINT_BRANCH_NAME_SCRIPT are set in setup()
  env MOCK_GIT_REV_PARSE="$branch_name" \
      PATH="$TEST_DIR/../mocks:$PATH" \
      "$BATS_SHELL" "$LINT_BRANCH_NAME_SCRIPT"
}

@test "Short ID is valid" {
  run lint_branch_name "abc-1"
  assert_success
}

@test "Long ID is valid" {
  run lint_branch_name "abcd-10000"
  assert_success
}

@test "HEAD is invalid but exits 0" {
  run lint_branch_name "HEAD"
  [ "$output" != "" ]
  assert_success
}

@test "Naive name is invalid and fails" {
  run lint_branch_name "my-branch"
  assert_failure
}

@test "Prefixed name is invalid and fails" {
  run lint_branch_name "feature-abcd-10000"
  assert_failure
}

@test "Uppercase name is invalid and fails" {
  run lint_branch_name "ABC-123"
  assert_failure
}

@test "Snake_case name is invalid and fails" {
  run lint_branch_name "abc-123-snake_case"
  assert_failure
}
