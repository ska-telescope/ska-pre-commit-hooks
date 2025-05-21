#! /bin/sh
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINT_BRANCH_NAME_SCRIPT=$TEST_DIR/../../lint-branch-name.sh

mock_git_branch_name() {
  local branch_name="$1"

  eval "
    git() {
      if [ \"\$1\" = \"rev-parse\" ] && [ \"\$2\" = \"--abbrev-ref\" ] && [ \"\$3\" = \"HEAD\" ]; then
        echo \"$branch_name\"
      else
        command git \"\$@\"
      fi
    }
  "
}

lint_branch_name() {
    mock_git_branch_name "$1"
    MSG=$(. $LINT_BRANCH_NAME_SCRIPT)
    local rc=$?
    echo "$MSG"
    return $rc
}

testShortId() {
    MSG=$(lint_branch_name "abc-1")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals "$RESULT" 0
}

testLongId() {
    MSG=$(lint_branch_name "abcd-10000")
    RESULT=$?
    assertEquals "" "$MSG"
    assertEquals "$RESULT" 0
}

testNaiveName() {
    MSG=$(lint_branch_name "my-branch")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals "$RESULT" 1
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
    assertEquals "$RESULT" 1
}

testSnakecaseName() {
    MSG=$(lint_branch_name "abc-123-snake_case")
    RESULT=$?
    assertNotEquals "" "$MSG"
    assertEquals "$RESULT" 1
}

# run
. shunit2
