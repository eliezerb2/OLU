FROM rockylinux:9.3

ENV UPDATER_COMMAND="/app/get-updates.sh"

# Run updates to get latest packages
RUN dnf update -y && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Install reposync dependency
RUN dnf install -y dnf-utils && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Create aliases
RUN echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias ll='ls -l'" >> /etc/bash.bashrc

# Copy scripts and files from docker/files to their corresponding locations in the image
COPY files/ /

# Ensure get-updates.sh is executable
RUN chmod +x ${UPDATER_COMMAND}

ENTRYPOINT ["sh", "-c", "while true; do date; sleep 3; done"]