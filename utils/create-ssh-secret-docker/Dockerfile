FROM bitnami/kubectl:latest

# Switch to root for package installation
USER root

# Install openssh-client (for ssh-keygen) + updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends openssh-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy scripts and files from docker/files to their corresponding locations in the image
COPY files/ /

RUN chmod +x /scripts/generate-ssh-secrets.sh
RUN chmod +x /scripts/unprefix_env_vars.sh

# Override the kubectl entrypoint
ENTRYPOINT []