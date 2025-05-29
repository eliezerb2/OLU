#!/bin/sh
set -e

# Load logging library
. /app/lib/logging.sh

# Function to ensure directory exists and set permissions
# Parameters:
#   $1: Directory path
#   $2: User to own the directory
#   $3: Permissions (e.g., 755)
ensure_directory_permissions() {
    local dir_path="$1"
    local owner="$2"
    local perms="$3"
    
    if [ -z "$dir_path" ]; then
        log_error "Directory path not provided"
        return 1
    fi
    
    log_info "Creating directory $dir_path"
    mkdir -p "$dir_path"
    
    if [ ! -d "$dir_path" ]; then
        log_error "Failed to create directory $dir_path"
        return 1
    fi
    
    log_debug "Setting ownership for $dir_path to $owner"
    chown -R "$owner:" "$dir_path"
    
    log_debug "Setting permissions for $dir_path to $perms"
    chmod -R "$perms" "$dir_path"
    
    return 0
}

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
if [ ! -d "$USER_SSH_PATH" ]; then
    log_error "Failed to create .ssh directory for $USER_NAME"
    exit 1
fi
log_debug "Setting ownership and permissions for $USER_SSH_PATH"
chown -R "$UPDATES_DOWNLOADER_SSH_JENKINS_USERNAME:" "$USER_SSH_PATH"
log_debug "Setting permissions for $USER_SSH_PATH"
chmod 700 "$USER_SSH_PATH"

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

log_info "Setting up environment for SSH sessions"
env | grep -E "^(UPDATER_|UPDATES_DOWNLOADER_)" > "$USER_ENV_PATH"
chmod 600 "$USER_ENV_PATH"
chown "$USER_NAME:" "$USER_ENV_PATH"

# Ensure user has write permissions to the updates directory
ensure_directory_permissions "$UPDATER_DOWNLOAD_DIR" "$USER_NAME" "755"

# Ensure user has write permissions to the log file directory
LOG_DIR=$(dirname "$UPDATER_LOG_FILE")
ensure_directory_permissions "$LOG_DIR" "$USER_NAME" "755"
touch "$UPDATER_LOG_FILE"
chown "$USER_NAME:" "$UPDATER_LOG_FILE"
chmod 666 "$UPDATER_LOG_FILE"  # More permissive to ensure write access

log_info "finished creating Jenkins SSH user $USER_NAME"