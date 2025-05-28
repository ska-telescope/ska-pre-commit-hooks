#!/usr/bin/env bats

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  LINT_COMMIT_MSG_SCRIPT="$TEST_DIR/../../lint-commit-msg.sh"
}

stub_git() {
  # only bash supports export -f
  export STUB_GIT_REV_PARSE="$1"
  export STUB_GIT_LOG="$2 $3"

  eval '
    git() {
      if [ "$1" = "rev-parse" ] && [ "$2" = "--abbrev-ref" ]; then
        echo "$STUB_GIT_REV_PARSE"
      elif [ "$1" = "log" ] && [ "$2" = "--format='%h %s'" ]; then
        echo "$STUB_GIT_LOG"
      else
        command git "$@"
      fi
    }
    export -f git
  '
}

lint_commit_msg() {
  # Run `lint-commit-msg.sh` at pre-commit stage mocking the specified arguments.
  #
  # Arguments:
  #   $1 - branch name
  #   $2 - commit message

  local branch_name="$1"
  local commit_msg="$2"

  stub_git $1
  local tmpfile
  tmpfile="$(mktemp)"
  echo "$commit_msg" > "$tmpfile"

  MSG=$("$LINT_COMMIT_MSG_SCRIPT" "$tmpfile")
  local rc=$?

  rm -f "$tmpfile"
  echo "$MSG"
  return $rc
}

@test "Valid commit message matches branch" {
  run lint_commit_msg "abc-123-my-branch" "ABC-123 my message"
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Short ID is valid" {
  run lint_commit_msg "abc-1" "ABC-1"
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Long ID is valid" {
  run lint_commit_msg "abcd-1" "ABCD-1"
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Multiple IDs, including matching one, are valid" {
  run lint_commit_msg "abc-1" "ABC-2 ABC-1"
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Invalid multiple IDs, wrong reference first" {
  run lint_commit_msg "abc-1" "ABC-2 but also related to ABC-1"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Auto merge message is valid" {
  run lint_commit_msg "abc-123" "Merge branch 'abc-123-extra' int 'abc-123'"
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Mismatch merge message fails" {
  run lint_commit_msg "abc-123" "ABC-234 Merge branch 'abc-123-extra' int 'abc-123'"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Mismatch ID in message fails" {
  run lint_commit_msg "abc-123-my-branch" "ABCD-123 my message"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Invalid ID format in message fails" {
  run lint_commit_msg "abc-123-my-branch" "ABC-12 my message"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Naive message without ID fails" {
  run lint_commit_msg "abc-123-my-branch" "my message"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Lowercase ID in message fails" {
  run lint_commit_msg "abc-123-my-branch" "abc-123 message"
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}
