
FROM registry.access.redhat.com/ubi9/ubi

ENV SCRIPTS_FOLDER_PATH=/opt/scripts

# Run updates to get latest packages
RUN dnf update -y && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Create aliases
RUN echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias ll='ls -l'" >> /etc/bash.bashrc

ENTRYPOINT ["sh", "-c", "while true; do date; sleep 3; done"]