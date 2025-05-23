FROM jenkins/jenkins:lts

ENV JENKINS_SERVICE_USER=jenkins
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false
ENV NEXUS_ADMIN_CREDENTIALS_ID=nexus-admin
ENV KUBECTL_VERSION=1.29.3
ENV KUBECTL_BIN_PATH=/usr/local/bin/kubectl
ENV KUBECTL_DOWNLOAD_URL="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

USER root

# Update packages (optional security hardening)
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create aliases
RUN echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias ll='ls -l'" >> /etc/bash.bashrc

# Copy scripts and files from docker/files to their corresponding locations in the image
COPY --chown=${JENKINS_SERVICE_USER}:${JENKINS_SERVICE_USER} files/ /

# Install required Jenkins plugins
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    credentials \
    credentials-binding \
    plain-credentials \
    script-security

# Install kubectl for Kubernetes access from Jenkins pod
RUN curl -LO "$KUBECTL_DOWNLOAD_URL" \
    && install -o root -g root -m 0755 kubectl $KUBECTL_BIN_PATH \
    && rm kubectl

USER ${JENKINS_SERVICE_USER}