#!/usr/bin/env bash
#
# Arguments
PR_NUMBER="$1"
BASE_BRANCH="$2"
HEAD_BRANCH="$3"

PR_COUNT=$(gh pr list --head $HEAD_BRANCH --base $BASE_BRANCH --json number --jq 'length')
PR_BODY="Automated backport from $SOURCE_BRANCH to ${BASE_BRANCH}"

if [[ $PR_COUNT -eq 0 ]]; then
  gh pr create -B $BASE_BRANCH -H $HEAD_BRANCH --title "backport: from ${HEAD_BRANCH} to $BASE_BRANCH" --body "🤖 This is an automatic backport from $HEAD_BRANCH to $BASE_BRANCH"
else
  echo "A PR from $HEAD_BRANCH to $BASE_BRANCH already exists."
  gh pr comment $PR_NUMBER --body "A PR from $HEAD_BRANCH to $BASE_BRANCH already exists."
fi
