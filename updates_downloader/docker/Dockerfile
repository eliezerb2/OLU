
FROM registry.access.redhat.com/ubi9/ubi

# Run updates to get latest packages
RUN dnf update -y && \
    dnf clean all && \
    rm -rf /var/cache/dnf