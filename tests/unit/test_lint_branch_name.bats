#!/usr/bin/env bats

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  LINT_BRANCH_NAME_SCRIPT="$TEST_DIR/../../lint-branch-name.sh"
}

stub_git() {
  # only bash supports export -f
  export STUB_GIT_REV_PARSE="$1"

  eval '
    git() {
      if [ "$1" = "rev-parse" ] && [ "$2" = "--abbrev-ref" ]; then
        echo "$STUB_GIT_REV_PARSE"
      else
        command git "$@"
      fi
    }
    export -f git
  '
}

lint_branch_name() {
  # Run `lint-branch-name.sh` mocking the specified arguments.
  #
  # Arguments:
  #   $1 - branch name

  local branch_name="$1"

  stub_git $branch_name

  # shellcheck disable=SC1090
  MSG=$("$LINT_BRANCH_NAME_SCRIPT")
  local rc=$?
  echo "$MSG"
  return $rc
}

@test "Short ID is valid" {
  run lint_branch_name "abc-1"
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Long ID is valid" {
  run lint_branch_name "abcd-10000"
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "HEAD is invalid but exits 0" {
  run lint_branch_name "HEAD"
  [ "$output" != "" ]
  [ "$status" -eq 0 ]
}

@test "Naive name is invalid and fails" {
  run lint_branch_name "my-branch"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Prefixed name is invalid and fails" {
  run lint_branch_name "feature-abcd-10000"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Uppercase name is invalid and fails" {
  run lint_branch_name "ABC-123"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Snake_case name is invalid and fails" {
  run lint_branch_name "abc-123-snake_case"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}
