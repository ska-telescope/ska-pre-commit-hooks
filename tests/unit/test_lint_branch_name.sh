#! /bin/sh
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
LINT_BRANCH_NAME_SCRIPT=$TEST_DIR/../../lint-branch-name.sh

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
  "
}

lint_branch_name() {
    # Run `lint-branch-name.sh` mocking the specified arguments. 
    #
    # Arguments:
    #   $1 - branch name

    mock_git_rev_parse "$1"
    MSG=$(. $LINT_BRANCH_NAME_SCRIPT)
    local rc=$?
    echo "$MSG"
    return $rc
}

testShortId() {
    MSG=$(lint_branch_name "abc-1")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testLongId() {
    MSG=$(lint_branch_name "abcd-10000")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testHead() {
    MSG=$(lint_branch_name "HEAD")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 0 "$RESULT"
}

testNaiveName() {
    MSG=$(lint_branch_name "my-branch")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testPrefixedName() {
    MSG=$(lint_branch_name "feature-abcd-10000")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals "$RESULT" 1
}

testUppercaseName() {
    MSG=$(lint_branch_name "ABC-123")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

testSnakecaseName() {
    MSG=$(lint_branch_name "abc-123-snake_case")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals 1 "$RESULT"
}

# run
. shunit2
