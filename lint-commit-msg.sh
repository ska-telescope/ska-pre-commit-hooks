#!/usr/bin/env bash
ARGS=$1
COMMIT_MSG=$(head -n1 "$ARGS")
BRANCH_TICKET_ID_REGEX="^([a-z]{2,}-[0-9]+)"
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

if [[ "$BRANCH_NAME" == "HEAD" ]]; then
    echo "ℹ️ Skipping branch name check: currently in detached HEAD (e.g., rebase or amend)"
    exit 0
fi

if ! [[ "$BRANCH_NAME" =~ $BRANCH_TICKET_ID_REGEX ]]; then
    echo "💥 Invalid branch name. Expected lowercase JIRA ticket prefix (e.g. abc-1234), but got '$BRANCH_NAME'"
    exit 1
fi
BRANCH_TICKET_ID=${BASH_REMATCH[1]}

PATTERN="^${BRANCH_TICKET_ID^^}|(Merge branch )"
if ! [[ "$COMMIT_MSG" =~ $PATTERN ]]; then
  echo "💥 Invalid commit message. Expected JIRA ticket pattern '$PATTERN' in commit message, but got '$COMMIT_MSG'"
  exit 1
fi
