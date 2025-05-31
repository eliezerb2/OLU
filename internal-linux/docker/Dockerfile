FROM rockylinux:9.3

# Install openssh-server
RUN dnf install -y openssh-server procps-ng net-tools iproute && \
    mkdir -p /var/run/sshd

# Clear package cache
RUN dnf clean all && \
    rm -rf /var/cache/dnf

# Create aliases
RUN echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias ll='ls -l'" >> /etc/bash.bashrc

# Copy scripts and files
COPY files/ /

# Ensure scripts are executable
RUN find /app -type f -name "*.sh" -exec chmod +x {} \;

# Use the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]