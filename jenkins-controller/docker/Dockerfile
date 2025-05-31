FROM jenkins/jenkins:lts

ARG MODULE_PATH
ENV JENKINS_SERVICE_USER=jenkins
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false
ENV NEXUS_ADMIN_CREDENTIALS_ID=nexus-admin

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
COPY --chown=${JENKINS_SERVICE_USER}:${JENKINS_SERVICE_USER} ${MODULE_PATH}/docker/files/ /

# Install required Jenkins plugins
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    credentials \
    credentials-binding \
    plain-credentials \
    script-security

USER ${JENKINS_SERVICE_USER}