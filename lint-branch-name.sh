#!/bin/env bash

BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
BRANCH_NAME_REGEX="^[a-z]{2,}-[0-9]+(-[0-9A-Za-z]+)*$"

if [[ "$BRANCH_NAME" == "HEAD" ]]; then
    echo "ℹ️ Skipping branch name check: currently in detached HEAD (e.g., rebase or amend)"
    exit 0
fi

if ! [[ "$BRANCH_NAME" =~ $BRANCH_NAME_REGEX ]]
then
    echo "💥 Invalid branch name. Expected a kebab-case name with JIRA ticket prefix (e.g. abc-1234), but got '$BRANCH_NAME'"
    exit 1
fi
