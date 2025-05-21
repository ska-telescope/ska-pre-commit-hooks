#! /bin/sh
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINT_COMMIT_MSG_SCRIPT=$TEST_DIR/../../lint-commit-msg.sh

mock_git_rev_parse() {
  MOCK_GIT_REV_PARSE="$1"
}

mock_git_log() {
  MOCK_GIT_LOG="$1"
}

# Unified mocked git command
mock_git() {
  export MOCK_GIT_REV_PARSE
  export MOCK_GIT_LOG
  eval '
    git() {
      if [ "$1" = "rev-parse" ] && [ "$2" = "--abbrev-ref" ]; then
        echo "$MOCK_GIT_REV_PARSE"
      elif [ "$1" = "log" ]; then
        echo "$MOCK_GIT_LOG"
      else
        command git "$@"
      fi
    }

    export -f git
  '
}

mock_commit_msg() {
    local tmpfile=$(mktemp)
    echo "$1" > $tmpfile
    echo "$tmpfile"
}

lint_pre_push() {
    # Run `lint-commit-msg.sh` at pre-push stage mocking the specified arguments.
    #
    # Arguments:
    #   $1 - branch name
    #   $2 - commit id
    #   $3 - commit message

    mock_git_rev_parse "$1"
    mock_git_log "$2 $3"
    mock_git
    PRE_COMMIT_TO_REF=1
    export PRE_COMMIT_TO_REF

    MSG=$(bash $LINT_COMMIT_MSG_SCRIPT)
    local rc=$?
    echo "$MSG"
    return $rc
}

testValidMsg() {
    MSG=$(lint_pre_push "abc-123-my-branch" "123456" "ABC-123 my message")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testShortId() {
    MSG=$(lint_pre_push "abc-1" "123456" "ABC-1")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testLongId() {
    MSG=$(lint_pre_push "abcd-1" "123456" "ABCD-1")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testMultipleId() {
    MSG=$(lint_pre_push "abc-1" "123456" "ABC-2 ABC-1")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testInvalidMultipleId() {
    MSG=$(lint_pre_push "abc-1" "123456" "ABC-2 but also related to ABC-1")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testAutoMergeMsg() {
    MSG=$(lint_pre_push "abc-123" "123456" "Merge branch 'abc-123-extra' int 'abc-123'")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testMismatchMergeMsg() {
    MSG=$(lint_pre_push "abc-123" "123456" "ABC-234 Merge branch 'abc-123-extra' int 'abc-123'")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testMismatchIdMsg() {
    MSG=$(lint_pre_push "abc-123-my-branch" "123456" "ABCD-123 my message")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testMismatchIdNoMsg() {
    MSG=$(lint_pre_push "abc-123-my-branch" "123456" "ABC-12 my message")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testNaiveMsg() {
    MSG=$(lint_pre_push "abc-123-my-branch" "123456" "my message")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testLowercaseMsg() {
    MSG=$(lint_pre_push "abc-123-my-branch" "123456" "abc-123 message")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

# run
. shunit2
