FROM ubuntu:22.04

# Arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG RUNNER_VERSION=2.311.0

# Set environment variables
ENV RUNNER_ALLOW_RUNASROOT=1
ENV RUNNER_VERSION=${RUNNER_VERSION}

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    iputils-ping \
    net-tools \
    openssh-client \
    software-properties-common \
    sudo \
    tar \
    unzip \
    wget \
    zip \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Docker cli
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Create a user for the runner
RUN groupadd docker && \
    useradd -m runner && \
    usermod -aG sudo runner && \
    usermod -aG docker runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set the working directory
WORKDIR /home/runner

# Create directories for the runner
RUN mkdir -p /home/runner/actions-runner

# Download and install GitHub Actions Runner
RUN cd /home/runner/actions-runner && \
    curl -o /tmp/actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf /tmp/actions-runner.tar.gz -C /home/runner/actions-runner && \
    rm /tmp/actions-runner.tar.gz && \
    chown -R runner:runner /home/runner/actions-runner

# Install runner dependencies
RUN cd /home/runner/actions-runner && ./bin/installdependencies.sh

# Copy runner script
COPY ./scripts/runner.sh /runner.sh
RUN chmod +x /runner.sh && \
    chown runner:runner /runner.sh

# Switch to the runner user
USER runner

# Set the entrypoint
ENTRYPOINT ["/runner.sh"]