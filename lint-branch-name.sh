#!/usr/bin/env bash

BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
BRANCH_NAME_REGEX="^HEAD$|^[a-z]{3,}-[0-9]+(-[0-9A-Za-z]+)*$"

if ! [[ $BRANCH_NAME =~ $BRANCH_NAME_REGEX ]]; then
    echo "💥 Invalid branch name. Expected a kebab-case name with JIRA ticket prefix (e.g. abc-1234), but got '$BRANCH_NAME'"
    exit 1
fi
