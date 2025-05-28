#!/bin/sh
set -e

# Load logging library
. /app/lib/logging.sh

USER_NAME=$UPDATES_DOWNLOADER_SSH_JENKINS_USERNAME
if [ -z "$USER_NAME" ]; then
    log_error "UPDATES_DOWNLOADER_SSH_JENKINS_USERNAME is not set"
    exit 1
fi
USER_HOME_PATH="/home/$USER_NAME"
USER_AUTHORIZED_KEYS_PATH="$USER_HOME_PATH/.ssh/authorized_keys"
AUTHORIZED_KEYS_MOUNT_PATH="/jenkins-public-key/authorized_keys"

log_info "Creating SSH user $USER_NAME"
useradd -m -s /bin/sh "$USER_NAME"
if ! id "$USER_NAME" 2>/dev/null; then
    log_error "Failed to create user $USER_NAME"
    exit 1
fi

log_info "Creating .ssh directory for $USER_NAME"
mkdir -p "$USER_HOME_PATH/.ssh"
if [ ! -d "$USER_HOME_PATH/.ssh" ]; then
    log_error "Failed to create .ssh directory for $USER_NAME"
    exit 1
fi
log_debug "Setting ownership and permissions for $USER_HOME_PATH/.ssh"
chown -R "$UPDATES_DOWNLOADER_SSH_JENKINS_USERNAME:" "$USER_HOME_PATH/.ssh"
log_debug "Setting permissions for $USER_HOME_PATH/.ssh"
chmod 700 "$USER_HOME_PATH/.ssh"

# If authorized_keys is present from Secret mount, copy it in
if [ ! -f "$AUTHORIZED_KEYS_MOUNT_PATH" ]; then
  log_error "No authorized_keys found in $AUTHORIZED_KEYS_MOUNT_PATH"
  exit
fi

log_debug "Copying authorized_keys from $AUTHORIZED_KEYS_MOUNT_PATH"
cp "$AUTHORIZED_KEYS_MOUNT_PATH" "$USER_AUTHORIZED_KEYS_PATH"
if [ ! -f "$USER_AUTHORIZED_KEYS_PATH" ]; then
    log_error "Failed to copy authorized_keys from $AUTHORIZED_KEYS_MOUNT_PATH"
    exit 1
fi

log_debug "Setting ownership and permissions for $USER_AUTHORIZED_KEYS_PATH"
chown "$USER_NAME:" "$USER_AUTHORIZED_KEYS_PATH"
log_debug "Setting permissions for $USER_AUTHORIZED_KEYS_PATH"
chmod 600 "$USER_AUTHORIZED_KEYS_PATH"

log_info "finished creating Jenkins SSH user $USER_NAME"