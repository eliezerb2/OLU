FROM jenkins/jenkins:lts

# Set environment variables
ENV INIT_GROOVY_FOLDER_PATH=/usr/share/jenkins/ref/init.groovy.d
ENV JENKINS_SERVICE_USER=jenkins

USER root

# Update packages (optional security hardening)
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create aliases
RUN echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias ll='ls -l'" >> /etc/bash.bashrc

# Create the target directory first to ensure proper permissions
RUN mkdir -p ${INIT_GROOVY_FOLDER_PATH} && \
    chown ${JENKINS_SERVICE_USER}:${JENKINS_SERVICE_USER} ${INIT_GROOVY_FOLDER_PATH} && \
    chmod 755 ${INIT_GROOVY_FOLDER_PATH}

# Copy Groovy scripts (note: must be run from directory containing 'groovy' folder)
COPY --chown=${JENKINS_SERVICE_USER}:${JENKINS_SERVICE_USER} groovy/ ${INIT_GROOVY_FOLDER_PATH}/

# Verify the copy operation
RUN ls -la ${INIT_GROOVY_FOLDER_PATH}

USER ${JENKINS_SERVICE_USER}