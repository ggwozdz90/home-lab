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

# Download the GitHub Actions runner
RUN mkdir -p /home/runner/actions-runner && \
    cd /home/runner/actions-runner && \
    curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    ./bin/installdependencies.sh && \
    chown -R runner:runner /home/runner

# Copy necessary scripts
COPY ./scripts/entrypoint.sh /entrypoint.sh
COPY ./scripts/cleanup.sh /cleanup.sh
RUN chmod +x /entrypoint.sh /cleanup.sh && \
    chown runner:runner /entrypoint.sh /cleanup.sh

# Switch to the runner user
USER runner

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]