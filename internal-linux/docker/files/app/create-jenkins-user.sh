#!/bin/sh
set -e

# Load logging library
. /app/lib/logging.sh

USER_NAME=$INTERNAL_LINUX_SSH_JENKINS_USERNAME
if [ -z "$USER_NAME" ]; then
    log_error "INTERNAL_LINUX_SSH_JENKINS_USERNAME is not set"
    exit 1
fi
USER_HOME_PATH="/home/$USER_NAME"
USER_SSH_PATH="$USER_HOME_PATH/.ssh"
USER_AUTHORIZED_KEYS_PATH="$USER_SSH_PATH/authorized_keys"
AUTHORIZED_KEYS_MOUNT_PATH="/jenkins-public-key/authorized_keys"
USER_ENV_PATH="$USER_SSH_PATH/environment"

log_info "Creating SSH user $USER_NAME"
useradd -m -s /bin/sh "$USER_NAME"
if ! id "$USER_NAME" 2>/dev/null; then
    log_error "Failed to create user $USER_NAME"
    exit 1
fi

log_info "Creating .ssh directory for $USER_NAME"
mkdir -p "$USER_SSH_PATH"
chown -R "$USER_NAME:" "$USER_SSH_PATH"
chmod 700 "$USER_SSH_PATH"

# Copy authorized_keys from Secret mount
if [ ! -f "$AUTHORIZED_KEYS_MOUNT_PATH" ]; then
  log_error "No authorized_keys found in $AUTHORIZED_KEYS_MOUNT_PATH"
  exit 1
fi

cp "$AUTHORIZED_KEYS_MOUNT_PATH" "$USER_AUTHORIZED_KEYS_PATH"
chown "$USER_NAME:" "$USER_AUTHORIZED_KEYS_PATH"
chmod 600 "$USER_AUTHORIZED_KEYS_PATH"

# Set up environment for SSH sessions
env | grep -E "^(INTERNAL_LINUX_)" > "$USER_ENV_PATH"
chmod 600 "$USER_ENV_PATH"
chown "$USER_NAME:" "$USER_ENV_PATH"

log_info "Finished creating Jenkins SSH user $USER_NAME"