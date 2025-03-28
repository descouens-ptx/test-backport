#!/usr/bin/env bash

ERROR=false
# Arguments
PR_NUMBER="$1"
SOURCE_BRANCH="$2"
PR_TITLE="[Backport] $3"

BACKPORT_BRANCH="backport-${SOURCE_BRANCH}-to-develop/pr-${PR_NUMBER}"
PR_COMMITS=$(gh pr view $PR_NUMBER --json commits | jq -r '.commits[].oid')
PR_BODY="Automated backport of #$PR_NUMBER to ${SOURCE_BRANCH}"

echo "git switch -c $BACKPORT_BRANCH $SOURCE_BRANCH"
git switch -c $BACKPORT_BRANCH $SOURCE_BRANCH

for commit in $PR_COMMITS; do
  echo "git cherry-pick $commit"
  if ! git cherry-pick $commit; then
    echo "Cannot cherry-pick commit $commit"
    ERROR=true
  fi
done

if [[ $ERROR == false ]]; then
  git push origin $BACKPORT_BRANCH
fi
