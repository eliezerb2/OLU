
FROM rockylinux:9.3

# Create aliases
RUN echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias ll='ls -l'" >> /etc/bash.bashrc

ENTRYPOINT ["sh", "-c", "while true; do date; sleep 3; done"]