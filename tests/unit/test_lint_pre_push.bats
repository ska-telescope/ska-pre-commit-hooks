#!/usr/bin/env bats

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  LINT_COMMIT_MSG_SCRIPT="$TEST_DIR/../../lint-commit-msg.sh"
  export PRE_COMMIT_TO_REF=1
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

@test "git rev-parse and log is mocked" {
  stub_git "mock-branch" "123" "msg"
  run bash -c "git rev-parse --abbrev-ref HEAD"
  [ "$output" = "mock-branch" ] || { echo "$output" >&2; false; }
  [ "$status" -eq 0 ] || { echo "$output" >&2; false; }

  run bash -c 'git log --format="%h %s"'
  [ "$output" = "123 msg" ]
  [ "$status" -eq 0 ]
}

@test "Valid commit message matches branch" {
  stub_git "abc-123-my-branch" "123456" "ABC-123 my message"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Short ID is valid" {
  stub_git "abc-1" "123456" "ABC-1"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Long ID is valid" {
  stub_git "abcd-1" "123456" "ABCD-1"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Multiple IDs, including matching one, are valid" {
  stub_git "abc-1" "123456" "ABC-2 ABC-1"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Invalid multiple IDs, wrong one first" {
  stub_git "abc-1" "123456" "ABC-2 but also related to ABC-1"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Invalid uppercase branch name" {
  stub_git "ABC-1" "123456" "ABC-1 message"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Auto merge message is valid" {
  stub_git "abc-123" "123456" "Merge branch 'abc-123-extra' int 'abc-123'"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "Mismatch merge message fails" {
  stub_git "abc-123" "123456" "ABC-234 Merge branch 'abc-123-extra' int 'abc-123'"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Mismatch ID in message fails" {
  stub_git "abc-123-my-branch" "123456" "ABCD-123 my message"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Invalid short ID fails" {
  stub_git "abc-123-my-branch" "123456" "ABC-12 my message"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Naive message with no ID fails" {
  stub_git "abc-123-my-branch" "123456" "my message"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" != "" ]
  [ "$status" -eq 1 ]
}

@test "Lowercase ID in message fails" {
  stub_git "abc-123-my-branch" "123456" "abc-123 message"
  run $LINT_COMMIT_MSG_SCRIPT
  [ "$output" != "" ]
  [ "$status" -eq 1 ]

  # [ "$output" != "" ] || { echo "$output" >&2; false; }
  # [ "$status" -eq 1 ] || { echo "$output" >&2; false; }
}
