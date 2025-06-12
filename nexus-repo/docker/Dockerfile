FROM sonatype/nexus3:latest

ARG MODULE_PATH
ENV APP_FOLDER_PATH=/app
ENV LOGS_FOLDER_PATH=/var/log

# Switch to root to perform privileged operations
USER root

# Install packages with microdnf
RUN microdnf update -y && \
    microdnf clean all

# Copy utils files first
COPY utils/docker/files/ /

# Copy module-specific files (will overwrite any conflicting files)
COPY ${MODULE_PATH}/docker/files/ /

# Set permissions for executables
RUN find ${APP_FOLDER_PATH} -type f -name "*.sh" -exec chmod +x {} \;

# set permissions for the logs
RUN chown -R nexus:nexus ${LOGS_FOLDER_PATH} && \
    chmod 755 ${LOGS_FOLDER_PATH}

# Switch back to nexus user (default in base image)
USER nexus

# Use the entrypoint script
ENTRYPOINT ${APP_FOLDER_PATH}/entrypoint.sh