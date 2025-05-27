#!/bin/bash

# define const regex
BRANCH_TICKET_ID_REGEX="[a-z]{2,}-[0-9]+"
BRANCH_NAME_REGEX="^($BRANCH_TICKET_ID_REGEX)(-[0-9A-Za-z]+)*$"
COMMIT_TICKET_ID_REGEX="[A-Z]{3,}-[0-9]+"

# cache common regex
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH_NAME" =~ $BRANCH_NAME_REGEX ]]; then
    COMMIT_TICKET_ID=${BASH_REMATCH[1]^^}
    COMMIT_MSG_REGEX="^($COMMIT_TICKET_ID_REGEX([, ]+)?)*$COMMIT_TICKET_ID([, ]+$COMMIT_TICKET_ID_REGEX)*|^Merge branch "
fi

if [ -n "$PRE_COMMIT_TO_REF" ]; then
    # Execute pre-push logic
    if ! [[ "$BRANCH_NAME" =~ $BRANCH_NAME_REGEX ]]; then
        echo "💥 Invalid branch name. Expected JIRA pattern like 'abc-1234', but got '$BRANCH_NAME'"
        exit 1
    fi

    # Identify all commits that haven't been pushed yet
    COMMIT_RANGE="$PRE_COMMIT_FROM_REF..$PRE_COMMIT_TO_REF"

    # Validate each commit message
    FAIL_COUNT=0
    MAX_FAILS=5
    while IFS= read -r LINE; do
        COMMIT_SHA=${LINE%% *}
        COMMIT_MSG=${LINE#* }
        if ! [[ "$COMMIT_MSG" =~ $COMMIT_MSG_REGEX ]]; then
            echo "💥 Commit [$COMMIT_SHA] '$COMMIT_MSG' does not start with expected pattern '$COMMIT_MSG_REGEX'"
            ((FAIL_COUNT++))
            if [ "$FAIL_COUNT" -ge "$MAX_FAILS" ]; then
                echo "🚫 Stopping after $MAX_FAILS failures."
                break
            fi
        fi
    done < <(git log --format='%h %s' "$COMMIT_RANGE")

    if [ "$FAIL_COUNT" -gt 0 ]; then
        echo "❌ Commit message check failed: $FAIL_COUNT invalid message(s) found."
        exit 1
    fi
else
    # Execute commit-msg logic
    if [[ "$BRANCH_NAME" == "HEAD" ]]; then
        echo "ℹ️ Skipping branch name check: currently in detached HEAD (e.g., rebase or amend)"
        exit 0
    fi
    if ! [[ "$BRANCH_NAME" =~ $BRANCH_TICKET_ID_REGEX ]]; then
        echo "💥 Invalid branch name. Expected lowercase JIRA ticket prefix (e.g. abc-1234), but got '$BRANCH_NAME'"
        exit 1
    fi

    # Validate message
    ARGS=$1
    COMMIT_MSG=$(head -n1 "$ARGS")
    if ! [[ "$COMMIT_MSG" =~ $COMMIT_MSG_REGEX ]]; then
        echo "💥 Invalid commit message. Expected JIRA ticket pattern '$COMMIT_MSG_REGEX' in commit message, but got '$COMMIT_MSG'"
        exit 1
    fi
fi
