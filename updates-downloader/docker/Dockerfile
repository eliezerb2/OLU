FROM rockylinux:9.3

ARG MODULE_PATH
ENV APP_FOLDER_PATH=/app

# Install reposync dependency
RUN dnf install -y dnf-utils

# Install openssh-server
RUN dnf install -y openssh-server
RUN mkdir -p /var/run/sshd

# Install debugging tools: ps (procps-ng), netstat (net-tools), ss (iproute)
RUN dnf install -y procps-ng net-tools iproute

# Clear package cache
RUN dnf clean all && \
    rm -rf /var/cache/dnf

# Create aliases
RUN echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias ll='ls -l'" >> /etc/bash.bashrc

# Copy utils files first
COPY utils/docker/files/ /

# Copy module-specific files (will overwrite any conflicting files)
COPY ${MODULE_PATH}/docker/files/ /

# Set permissions for executables
RUN find ${APP_FOLDER_PATH} -type f -name "*.sh" -exec chmod +x {} \;

# Use the entrypoint script
ENTRYPOINT ${APP_FOLDER_PATH}/entrypoint.sh