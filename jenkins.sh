#!/bin/bash

# We can remove the gh-status code when we move to Jenkins 2
GH_STATUS_REPO_NAME=${INITIATING_REPO_NAME:-"alphagov/local-links-manager"}
CONTEXT_MESSAGE=${CONTEXT_MESSAGE:-"default"}
GH_STATUS_GIT_COMMIT=${INITIATING_GIT_COMMIT:-${GIT_COMMIT}}

function github_status {
  STATUS="$1"
  MESSAGE="$2"
}

function error_handler {
  trap - ERR # disable error trap to avoid recursion
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  github_status error "errored on Jenkins"
  exit "${code}"
}

trap 'error_handler ${LINENO}' ERR
github_status pending "is running on Jenkins"

# Cleanup anything left from previous test runs
git clean -fdx

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

export RAILS_ENV=test
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment --without development

# Lint changes introduced in this branch, but not for master
if [[ ${GIT_BRANCH} != "origin/master" ]]; then
  bundle exec govuk-lint-ruby \
  --diff \
  --cached \
  --format html --out rubocop-${GIT_COMMIT}.html \
  --format clang \
  app spec lib
fi

bundle exec rails db:drop db:create db:environment:set db:schema:load

if bundle exec rails ${TEST_TASK:-"default"}; then
  github_status success "succeeded on Jenkins"
else
  github_status failure "failed on Jenkins"
  exit 1
fi
