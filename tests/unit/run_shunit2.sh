#! /bin/bash

SHELLS=(
    /bin/bash
    /bin/zsh

    # "export -f" not supported
    # /bin/dash
    # /bin/ksh
    # /bin/mksh
)

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_FILES=(
  "test_lint_branch_name.sh"
  "test_lint_commit_msg.sh"
  "test_lint_pre_push.sh"
)

overall_exit=0

for test_file in "${TEST_FILES[@]}"; do
  echo "=== Testing $test_file ==="
  for shell in "${SHELLS[@]}"; do
    if [ -x "$shell" ]; then
      echo "=== Running with $shell ==="
    
      if [ "$shell" = "/bin/zsh" ]; then
        # Run the shell interactively, defining the array
        # and sourcing test file in same session
        "$shell" -c '
          setopt shwordsplit
          SHUNIT_PARENT=$0
          "'"$TEST_DIR/$test_file"'"
        '
      else
        "$shell" "$TEST_DIR/$test_file"
      fi
      status=$?
      if [ "$status" -ne 0 ]; then
        overall_exit=1
      fi
      echo
    else
      echo "!! Skipping $shell $test_file (not executable)"
    fi
  done
done

exit $overall_exit