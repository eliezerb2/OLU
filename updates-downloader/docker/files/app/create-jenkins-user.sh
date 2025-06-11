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
env | grep -E "^(UPDATES_DOWNLOADER_)" > "$USER_ENV_PATH"
chmod 600 "$USER_ENV_PATH"
chown "$USER_NAME:" "$USER_ENV_PATH"

# Create download directory and set permissions
if [ ! -z "$UPDATER_DOWNLOAD_DIR" ]; then
    log_info "Creating download directory $UPDATER_DOWNLOAD_DIR"
    mkdir -p "$UPDATER_DOWNLOAD_DIR"
    chmod 775 "$UPDATER_DOWNLOAD_DIR"
    chown -R "$USER_NAME:" "$UPDATER_DOWNLOAD_DIR"
fi

# Create log directory and set permissions
if [ ! -z "$UPDATER_LOG_FILE" ]; then
    LOG_DIR=$(dirname "$UPDATER_LOG_FILE")
    log_info "Creating log directory $LOG_DIR"
    mkdir -p "$LOG_DIR"
    chmod 775 "$LOG_DIR"
    touch "$UPDATER_LOG_FILE"
    chmod 664 "$UPDATER_LOG_FILE"
    chown -R "$USER_NAME:" "$LOG_DIR"
fi

log_info "Finished creating Jenkins SSH user $USER_NAME"