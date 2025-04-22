# Self-hosted GitHub Actions Runner

This directory contains the Docker configuration to run self-hosted GitHub Actions runners that can be connected to your GitHub repositories.

## Features

- Runs on a lightweight Ubuntu 22.04 base image
- Supports repository-level runners
- Docker-in-Docker capability for building container images in workflows
- Automatic registration and deregistration with GitHub
- Persistent storage for runner work directory and configuration
- Supports custom labels for targeted workflow runs

## Prerequisites

- Docker and Docker Compose installed on the host machine
- GitHub Personal Access Token (PAT) with appropriate permissions:
  - For repository runners: `repo` scope
- Access to Docker socket on the host

## Configuration

1. Copy the example environment file and modify it with your settings:

```bash
cp .env.example .env
```

2. Edit the `.env` file and set the following parameters:

- `GITHUB_URL`: URL of your GitHub repository or organization
  - For repository: `https://github.com/username/repo`
  - For organization: `https://github.com/organization`
- `GITHUB_TOKEN`: Your GitHub Personal Access Token
- `GITHUB_RUNNER_NAME`: (Optional) Custom name for your runner
- `GITHUB_RUNNER_LABELS`: (Optional) Custom labels for your runner
- `GITHUB_RUNNER_GROUP`: (Optional) Runner group (defaults to "Default")

## Usage

### Starting Runner

To start a single GitHub Actions runner:

```bash
docker-compose up -d
```

### Stopping Runner

To stop and remove the runners:

```bash
docker-compose down
```

The cleanup script will automatically deregister the runners from GitHub.

## Volume Management

The runner uses the following persistent volumes:

- `/home/runner/_work`: Working directory for job execution
- `/home/runner/.runner`: Runner configuration

These are mapped to the host path specified by the `DOCKER_VOLUMES` variable in your `.env` file.

## Security Considerations

- The GitHub token is used only for runner registration and deregistration
- The token is passed as an environment variable and not stored permanently
- The container needs access to the Docker socket, which gives it elevated privileges

## GitHub Actions Workflow Example

```yaml
name: Build and Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: self-hosted # This targets your self-hosted runner
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: docker build -t my-app .
      
    - name: Test
      run: docker run my-app npm test
```
