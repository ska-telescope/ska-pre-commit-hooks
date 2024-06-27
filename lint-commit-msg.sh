#!/usr/bin/env bash
ARGS=$1
COMMIT_MSG=$(head -n1 "$ARGS")
TICKET_ID_REGEX="^([a-z]{3,}-[0-9]+)"

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
if ! [[ $BRANCH_NAME =~ $TICKET_ID_REGEX ]]; then
    echo "💥 Invalid branch name. Expected lowercase JIRA ticket prefix (e.g. abc-1234), but got '$BRANCH_NAME'"
    exit 1
fi

BRANCH_TICKET_ID=${BASH_REMATCH[1]}
TICKET_PATTERN=$(echo "^${BRANCH_TICKET_ID}" | tr "[:lower:]" "[:upper:]")
MERGE_PATTERN="$TICKET_PATTERN|^Merge branch ";
MERGE_FILE=.git/MERGE_HEAD;

if ! [[ -f $MERGE_FILE ]]; then
    if ! [[ "$COMMIT_MSG" =~ $TICKET_PATTERN ]]; then
        echo "💥 Invalid commit message. Expected pattern '$TICKET_PATTERN' in commit message, but got '$COMMIT_MSG'"
        exit 1
    fi
else
    if ! [[ "$COMMIT_MSG" =~ $MERGE_PATTERN ]]; then
        echo "💥 Invalid merge commit message. Expected pattern '$MERGE_PATTERN' in commit message, but got '$COMMIT_MSG'"
        exit 1
    fi
fi
