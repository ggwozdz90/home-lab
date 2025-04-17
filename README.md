# Home Lab Setup

## Overview

This repository sets up a multi-container home lab using Docker and Docker Compose.

## Directory Structure

- **docker/**: Contains service directories with Dockerfiles, environment files, and Compose files.
- **docs/**: Detailed usage and configuration documentation.
- **README.md**: Overview and setup instructions.

## Getting Started

1. Clone the repository.
2. Navigate to the docker directory.
3. Run the following command:

    ```bash
    docker-compose up -d
    ```

4. Follow the configuration details in `docs/configuration.md` for further customization.

## Services

- **Watchtower**: Automatically updates containers.
- **Portainer**: Web-based container management. Use port [9443](https://localhost:9443/#!/home) to access.
- **SpeechToTextAPI**: Converts speech to text using OpenAI Whisper model. Use port [9001](http://localhost:9001/docs) to access.
- **SummarizationAPI**: Summarizes text using Facebook's Bart Large CNN model. Use port [9002](http://localhost:9002/docs) to access.
- **TranslationAPI**: Translates text using Facebook's Seamless M4T v2 Large model. Use port [9003](http://localhost:9003/docs) to access.
- **GitHub Actions Runner**: Self-hosted runner for GitHub Actions workflows. For complete documentation, see [GitHub Actions Runner Documentation](docker/github-actions-runner/README.md).
