#!/bin/bash
set -e

RUNNER_CONFIG_DIR=/home/runner/actions-runner
RUNNER_DATA_DIR=/home/runner/.runner
RUNNER_MARKER_FILE="${RUNNER_DATA_DIR}/registered"

# Function for logging
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $1"
}

# Function for error logging
error_log() {
  log "ERROR: $1"
}

# Check required environment variables
if [[ -z "${GITHUB_URL}" ]]; then
  error_log "GITHUB_URL is not set"
  exit 1
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
  error_log "GITHUB_TOKEN is not set"
  exit 1
fi

log "Starting runner cleanup process..."
cd ${RUNNER_CONFIG_DIR}

# Check if the runner is registered
if [ ! -f ".runner" ]; then
  log "Runner not registered, no cleanup needed"
  rm -f "${RUNNER_MARKER_FILE}"
  exit 0
fi

# Extract owner and repo from GITHUB_URL
if [[ ${GITHUB_URL} == *"github.com"* ]]; then
  # It's a GitHub repo URL
  GITHUB_OWNER_REPO=$(echo ${GITHUB_URL} | sed 's/.*github.com\/\(.*\)/\1/' | sed 's/\.git$//')
  
  # Determine if it's an organization or user repository
  if [[ ${GITHUB_OWNER_REPO} == *"/"* ]]; then
    # It's a repository
    REMOVAL_URL="https://api.github.com/repos/${GITHUB_OWNER_REPO}/actions/runners/remove-token"
  else
    # It's an organization
    REMOVAL_URL="https://api.github.com/orgs/${GITHUB_OWNER_REPO}/actions/runners/remove-token"
  fi
else
  # It's a GitHub Enterprise URL
  log "GitHub Enterprise URL detected"
  REMOVAL_URL="${GITHUB_URL}/actions/runners/remove-token"
fi

# Get the runner ID from the .runner file
RUNNER_ID=$(cat .runner | jq -r .runerId 2>/dev/null || echo "unknown")
log "Removing runner ID: ${RUNNER_ID}"
  
# Get a remove token
log "Getting remove token from ${REMOVAL_URL}"
PAYLOAD=$(curl -sX POST -H "Authorization: token ${GITHUB_TOKEN}" ${REMOVAL_URL})
REMOVE_TOKEN=$(echo ${PAYLOAD} | jq -r .token)
  
if [[ -z "${REMOVE_TOKEN}" || "${REMOVE_TOKEN}" == "null" ]]; then
  error_log "Failed to get remove token"
  error_log "Response payload: ${PAYLOAD}"
  # Continue with cleanup even if token retrieval fails
  # This ensures we clean up local files
else
  # Remove the runner
  log "Removing runner from GitHub..."
  ./config.sh remove --token "${REMOVE_TOKEN}" || error_log "Failed to remove runner from GitHub"
  log "Runner removal from GitHub completed"
fi

# Clean up local registration state
log "Cleaning up local runner configuration"
rm -f "${RUNNER_MARKER_FILE}"

log "Runner cleanup completed successfully"
exit 0