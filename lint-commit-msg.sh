#!/usr/bin/env bash
ARGS=$1
COMMIT_MSG=$(head -n1 "$ARGS")
TICKET_ID_REGEX="^([a-z]{3}-[0-9]+)|(Merge branch )"

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
if ! [[ $BRANCH_NAME =~ $TICKET_ID_REGEX ]]; then
    echo "💥 Invalid branch name. Expected lowercase JIRA ticket prefix (e.g. abc-1234), but got '$BRANCH_NAME'"
    exit 1
fi
BRANCH_TICKET_ID=${BASH_REMATCH[1]}

PATTERN="^${BRANCH_TICKET_ID^^}"
if ! [[ "$COMMIT_MSG" =~ $PATTERN ]]; then
  echo "💥 Invalid commit message. Expected JIRA ticket pattern '$PATTERN' in commit message, but got '$COMMIT_MSG'"
  exit 1
fi
