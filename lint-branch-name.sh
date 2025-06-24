#!/usr/bin/env sh

BRANCH_TICKET_ID_REGEX='[a-z]{2,}-[0-9]+'
BRANCH_NAME_REGEX="^${BRANCH_TICKET_ID_REGEX}(-[0-9A-Za-z]+)*$"

BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
if [ "$BRANCH_NAME" = "HEAD" ]; then
    echo "ℹ️ Skipping branch name check: currently in detached HEAD (e.g., rebase or amend)"
    exit 0
fi

echo "$BRANCH_NAME" | grep -Eq "$BRANCH_NAME_REGEX"
if [ $? -ne 0 ]; then
    echo "💥 Invalid branch name. Expected a kebab-case name with JIRA ticket prefix (e.g. abc-1234), but got '$BRANCH_NAME'"
    exit 1
fi
