#!/bin/sh
set -e

# Load logging library
. /app/lib/logging.sh

# Run the Jenkins user creation/setup script
/app/create-jenkins-user.sh

# Start sshd in the background, logging to a file
log_info "Starting sshd"
/usr/sbin/sshd -E /var/log/sshd.log -p "$UPDATES_DOWNLOADER_SSH_PORT"

# Tail sshd log to stdout
log_info "Tailing sshd log"
exec tail -F /var/log/sshd.log