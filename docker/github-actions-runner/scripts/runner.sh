#!/bin/bash
set -e

# Common variable definitions
RUNNER_WORK_DIR=/home/runner/_work
RUNNER_CONFIG_DIR=/home/runner/actions-runner

# Fix Docker socket permissions
if [ -e "/var/run/docker.sock" ]; then
  echo "Setting proper permissions for Docker socket..."
  sudo chmod 666 /var/run/docker.sock
fi

# Extract repository name from GITHUB_URL
REPOSITORY=$(echo ${GITHUB_URL} | sed 's/.*github.com\/\(.*\)/\1/' | sed 's/\.git$//')
ACCESS_TOKEN=${GITHUB_TOKEN}

echo "REPOSITORY ${REPOSITORY}"

# Get registration token
REG_TOKEN=$(curl -s -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

if [[ -z "${REG_TOKEN}" || "${REG_TOKEN}" == "null" ]]; then
  echo "ERROR: Failed to get registration token. Check your token permissions."
  exit 1
fi

cd ${RUNNER_CONFIG_DIR}

# Define cleanup function
cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${REG_TOKEN}
}

# Set up trap to handle signals
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Configure the runner
echo "Configuring runner..."
./config.sh \
  --url ${GITHUB_URL} \
  --token ${REG_TOKEN} \
  --name ${GITHUB_RUNNER_NAME} \
  --labels ${GITHUB_RUNNER_LABELS} \
  --runnergroup ${GITHUB_RUNNER_GROUP} \
  --work ${RUNNER_WORK_DIR} \
  --unattended \
  --replace

echo "Starting runner..."
./run.sh & wait $!