#!/usr/bin/env bash

ERROR=false
# Arguments
PR_NUMBER="$1"
BASE_BRANCH="$2"
PR_URL="$3"

BACKPORT_BRANCH="backport-to-${BASE_BRANCH}/pr-${PR_NUMBER}"
PR_COMMITS=$(gh pr view $PR_NUMBER --json commits | jq -r '.commits[].oid')
PR_BODY="Automated backport of #$PR_NUMBER to ${SOURCE_BRANCH}"

echo "git switch -c $BACKPORT_BRANCH $BASE_BRANCH"
git switch -c $BACKPORT_BRANCH $BASE_BRANCH

for commit in $PR_COMMITS; do
  echo "git cherry-pick $commit"
  if ! git cherry-pick $commit; then
    echo "Cannot cherry-pick commit $commit"
    ERROR=true
  fi
done

if [[ $ERROR == false ]]; then
  git push origin $BACKPORT_BRANCH
  gh pr create -B $BASE_BRANCH -H $BACKPORT_BRANCH --title "backport: to $SOURCE_BRANCH" --body "This is a backport of the Pull Request #$PR_NUMBER: $PR_URL"
else
  echo "Could not cherry pick the commit."
  exit 1
fi
