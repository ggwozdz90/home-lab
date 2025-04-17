#!/bin/bash
set -e

RUNNER_WORK_DIR=${GITHUB_RUNNER_WORK_DIR:-/home/runner/_work}
RUNNER_CONFIG_DIR=/home/runner/actions-runner
RUNNER_DATA_DIR=/home/runner/.runner
RUNNER_MARKER_FILE="${RUNNER_DATA_DIR}/registered"

# Improved signal handling
cleanup() {
  echo "Received termination signal, starting cleanup..."
  bash /cleanup.sh
  exit 0
}

# Trap multiple signals
trap cleanup SIGTERM SIGINT SIGQUIT

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

# Configure the runner
cd ${RUNNER_CONFIG_DIR}

# Create directories if they don't exist
mkdir -p ${RUNNER_WORK_DIR}
mkdir -p ${RUNNER_DATA_DIR}

# Check for previous registration state
NEEDS_REGISTRATION=true
if [ -f "${RUNNER_DATA_DIR}/registered" ]; then
  log "Runner was previously registered, checking status..."
  
  # Get runner ID from the .runner file if it exists
  if [ -f ".runner" ]; then
    RUNNER_ID=$(cat .runner | jq -r .runerId 2>/dev/null)
    if [[ ! -z "${RUNNER_ID}" && "${RUNNER_ID}" != "null" ]]; then
      log "Found existing runner ID: ${RUNNER_ID}"
      
      # Extract owner and repo from GITHUB_URL for API call
      if [[ ${GITHUB_URL} == *"github.com"* ]]; then
        GITHUB_OWNER_REPO=$(echo ${GITHUB_URL} | sed 's/.*github.com\/\(.*\)/\1/' | sed 's/\.git$//')
        
        # Check if runner is still registered with GitHub
        if [[ ${GITHUB_OWNER_REPO} == *"/"* ]]; then
          # Repository runner
          STATUS_URL="https://api.github.com/repos/${GITHUB_OWNER_REPO}/actions/runners"
        else
          # Organization runner
          STATUS_URL="https://api.github.com/orgs/${GITHUB_OWNER_REPO}/actions/runners"
        fi
        
        log "Checking runner status at ${STATUS_URL}"
        RUNNERS_DATA=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" "${STATUS_URL}")
        RUNNER_EXISTS=$(echo ${RUNNERS_DATA} | jq -r ".runners[] | select(.id == ${RUNNER_ID}) | .id" 2>/dev/null)
        
        if [[ "${RUNNER_EXISTS}" == "${RUNNER_ID}" ]]; then
          log "Runner is still registered and active"
          NEEDS_REGISTRATION=false
        else
          log "Runner is no longer registered with GitHub, will re-register"
          rm -f "${RUNNER_DATA_DIR}/registered" .runner
        fi
      fi
    else
      log "Could not find valid runner ID, will re-register"
      rm -f "${RUNNER_DATA_DIR}/registered"
    fi
  else
    log "Runner configuration not found, will re-register"
    rm -f "${RUNNER_DATA_DIR}/registered"
  fi
fi

# Register the runner if needed
if [ "$NEEDS_REGISTRATION" = true ]; then
  log "Registering runner..."
  
  # Extract owner and repo from GITHUB_URL
  if [[ ${GITHUB_URL} == *"github.com"* ]]; then
    # It's a GitHub repo URL
    GITHUB_OWNER_REPO=$(echo ${GITHUB_URL} | sed 's/.*github.com\/\(.*\)/\1/' | sed 's/\.git$//')
    
    # Determine if it's an organization or user repository
    if [[ ${GITHUB_OWNER_REPO} == *"/"* ]]; then
      # It's a repository
      REGISTRATION_URL="https://api.github.com/repos/${GITHUB_OWNER_REPO}/actions/runners/registration-token"
    else
      # It's an organization
      REGISTRATION_URL="https://api.github.com/orgs/${GITHUB_OWNER_REPO}/actions/runners/registration-token"
    fi
  else
    # It's a GitHub Enterprise URL
    log "GitHub Enterprise URL detected"
    REGISTRATION_URL="${GITHUB_URL}/actions/runners/registration-token"
  fi
  
  log "Getting registration token from ${REGISTRATION_URL}"
  PAYLOAD=$(curl -sX POST -H "Authorization: token ${GITHUB_TOKEN}" ${REGISTRATION_URL})
  RUNNER_TOKEN=$(echo ${PAYLOAD} | jq -r .token)
  
  if [[ -z "${RUNNER_TOKEN}" || "${RUNNER_TOKEN}" == "null" ]]; then
    error_log "Failed to get registration token"
    error_log "Response payload: ${PAYLOAD}"
    exit 1
  fi
  
  # Generate a unique runner name with a timestamp suffix if not provided
  if [[ -z "${GITHUB_RUNNER_NAME}" ]]; then
    GITHUB_RUNNER_NAME="runner-$(date +%s)"
  fi
  
  # Configure the runner
  ./config.sh \
    --url ${GITHUB_URL} \
    --token ${RUNNER_TOKEN} \
    --name ${GITHUB_RUNNER_NAME} \
    --labels ${GITHUB_RUNNER_LABELS:-self-hosted,Linux,X64,docker} \
    --runnergroup ${GITHUB_RUNNER_GROUP:-Default} \
    --work ${RUNNER_WORK_DIR} \
    --unattended \
    --replace
  
  # Mark as registered
  touch "${RUNNER_DATA_DIR}/registered"
  log "Runner successfully registered"
fi

# Start the runner
log "Starting runner ${GITHUB_RUNNER_NAME}"
exec ./run.sh