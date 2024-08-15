#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_CICD_POC_TOKEN" ]; then
  echo -e "${RED}Error: GITHUB_TOKEN environment variable is not set.${NC}"
  exit 1
fi

# Get the current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Check if the branch name starts with "feature"
if [[ ! $current_branch =~ ^[Ff]eature ]]; then
  echo -e "${RED}Error: The current branch not a feature branch. Please switch to a feature branch to execute this task.${NC}"
  echo -e "${RED}Please execute command 'git checkout <Feature branch name>.${NC}"
  exit 1
fi

echo -e "${GREEN}Your current branch: $current_branch${NC}"

# Check if the current branch is ahead or behind its remote counterpart
status=$(git status -uno)
if [[ $status == *"Your branch is ahead"* || $status == *"have diverged"* ]]; then
  echo -e "${RED}Your branch is not in sync with the remote branch. Please commit and push your changes. then re-execute the 'SIT Deployment' task.${NC}"
  exit 1
fi

# Checkout the SIT branch and pull the latest changes
git checkout sit
git pull origin sit

# Checkout back to the current branch
git checkout "$current_branch"

# Merge the SIT branch into the current branch
echo -e "${GREEN}Merging SIT into $current_branch...${NC}"
git merge sit

# Check for merge conflicts
if [ $? -ne 0 ]; then
  echo -e "${RED}Merge conflicts detected.${NC}"
  echo -e "${RED}Please resolve the conflcits properly, and then stage and commit. ${NC}"
  echo -e "${RED}Push the feature branch to remote and then re-execute the 'SIT Deployment' task ${NC}"
  exit 1
fi

echo -e "${GREEN} No Conflcits, merge completed successfully.${NC}"
echo -e "${YELLOW} Creating PR from '$current_branch' branch to 'sit' branch.${NC}"

# Create a PR from the current branch to the sit branch
PR_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_CICD_POC_TOKEN" \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Merge '"$current_branch"' into sit",
    "head": "'"$current_branch"'",
    "base": "sit",
    "body": "Auto-generated pull request to merge '"$current_branch"' into sit"
  }' \
  https://api.github.com/repos/aswath-n/CRM-SFDC-Test/pulls)


# Check if the PR was created successfully and extract the URL
PR_URL=$(echo "$PR_RESPONSE" | grep '"html_url"' | head -n 1 | sed 's/.*"html_url": "\(.*\)",/\1/')

if [[ $PR_URL != "null" ]]; then
  echo -e "${GREEN}Pull request created successfully: $PR_URL${NC}"
else
  echo -e "${RED}Failed to create pull request. Response from GitHub:${NC}"
  echo "$PR_RESPONSE"
  exit 1
fi