FROM rockylinux:9.3

ARG MODULE_PATH
ENV APP_FOLDER_PATH=/app

# Install openssh-server
RUN dnf install -y openssh-server procps-ng net-tools iproute && \
    mkdir -p /var/run/sshd

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

# TODO: give only jenkins permissions to yum.repos.d, and not all users
RUN chmod 777 /etc/yum.repos.d/

# Use the entrypoint script
ENTRYPOINT ${APP_FOLDER_PATH}/entrypoint.sh