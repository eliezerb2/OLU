FROM rockylinux:9.3

ENV UPDATER_COMMAND="/app/get-updates.sh"

# Run updates to get latest packages
RUN dnf update -y && \
    dnf clean all && \
    rm -rf /var/cache/dnf

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

# Copy scripts and files from docker/files to their corresponding locations in the image
COPY files/ /

# Ensure scripts are executable
RUN find /app -type f -name "*.sh" -exec chmod +x {} \;

# Use the new entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]