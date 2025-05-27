#! /bin/bash

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
LINT_COMMIT_MSG_SCRIPT=$TEST_DIR/../../lint-commit-msg.sh

mock_git_rev_parse() {
  local branch_name="$1"

  eval "
    git() {
      rev_parse_args=("rev-parse" "--abbrev-ref" "HEAD")
      if [[ \"\$@\" = \"\${rev_parse_args[@]}\" ]]; then
        echo \"$branch_name\"
      else
        command git \"\$@\"
      fi
    }
    export -f git
  "
}

mock_commit_msg() {
    local tmpfile=$(mktemp)
    echo "$1" > $tmpfile
    echo "$tmpfile"
}

lint_commit_msg() {
    # Run `lint-commit-msg.sh` at pre-commit stage mocking the specified arguments.
    #
    # Arguments:
    #   $1 - branch name
    #   $2 - commit message

    mock_git_rev_parse "$1"
    local commit_msg_file=$(mock_commit_msg "$2")
    MSG=$($LINT_COMMIT_MSG_SCRIPT $commit_msg_file)
    local rc=$?
    rm -f "$commit_msg_file"
    echo "$MSG"
    return $rc
}

testValidMsg() {
    MSG=$(lint_commit_msg "abc-123-my-branch" "ABC-123 my message")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testShortId() {
    MSG=$(lint_commit_msg "abc-1" "ABC-1")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testLongId() {
    MSG=$(lint_commit_msg "abcd-1" "ABCD-1")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testAutoMergeMsg() {
    MSG=$(lint_commit_msg "abc-123" "Merge branch 'abc-123-extra' int 'abc-123'")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testMismatchIdMsg() {
    MSG=$(lint_commit_msg "abc-123-my-branch" "ABCD-123 my message")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testMismatchIdNoMsg() {
    MSG=$(lint_commit_msg "abc-123-my-branch" "ABC-12 my message")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testNaiveMsg() {
    MSG=$(lint_commit_msg "abc-123-my-branch" "my message")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testLowercaseMsg() {
    MSG=$(lint_commit_msg "abc-123-my-branch" "abc-123 message")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

# run
. shunit2
