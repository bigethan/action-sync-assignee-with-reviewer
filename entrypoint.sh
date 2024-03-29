#!/bin/bash
set -eu

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_NAME" ]]; then
  echo "Set the GITHUB_EVENT_NAME env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

API_HEADER="Accept: application/vnd.github.v3+json; application/vnd.github.antiope-preview+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
reviewer=$(jq --raw-output .requested_reviewer.login "$GITHUB_EVENT_PATH")
# THEDATA=$(jq --raw-output . "$GITHUB_EVENT_PATH")

update_review_request() {

#  echo $THEDATA
  echo "curl -sSL \\"
  echo "  -H \"Content-Type: application/json\" \\"
  echo "  -H \"${AUTH_HEADER}\" \\"
  echo "  -H \"${API_HEADER}\" \\"
  echo "  -X $1 \\"
  echo "  -d \"{\"assignees\":[\"${reviewer}\"]}\" \\"
  echo "  \"https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${number}/assignees\""

  curl -sSL \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X $1 \
    -d "{\"assignees\":[\"${reviewer}\"]}" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${number}/assignees"
}

if [[ "$action" == "review_requested" ]]; then
  update_review_request 'POST'
elif [[ "$action" == "review_request_removed" ]]; then
  update_review_request 'DELETE'
else
  echo "Ignoring action ${action}"
  exit 0
fi
