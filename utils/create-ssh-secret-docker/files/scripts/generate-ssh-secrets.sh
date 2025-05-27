#!/bin/sh
set -e
log() {
  echo "[generate-ssh-secrets][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error_exit() {
  echo "[generate-ssh-secrets][$(date '+%Y-%m-%d %H:%M:%S')][ERROR] $1" >&2
  exit 1
}

create_secret() {
  # $1: secret name, $2: --from-file args
  local secret_name="$1"
  local from_file_args="$2"
  log "Deleting old secret $secret_name if it exists..."
  kubectl delete secret "$secret_name" --ignore-not-found \
    || log "Warning: failed to delete $secret_name"
  log "Creating secret $secret_name..."
  kubectl create secret generic "$secret_name" $from_file_args \
    --dry-run=client -o yaml | kubectl apply -f - \
    || error_exit "Failed to create $secret_name"
}

log "Starting..."

# Create the Jenkins SSH user and home if not present
log "Ensuring SSH user $JENKINS_SSH_USER_NAME exists..."
id "$JENKINS_SSH_USER_NAME" 2>/dev/null || useradd -m -s /bin/sh "$JENKINS_SSH_USER_NAME" \
  || error_exit "Failed to create user $JENKINS_SSH_USER_NAME"
mkdir -p /home/$JENKINS_SSH_USER_NAME/.ssh \
  || error_exit "Failed to create .ssh directory"
chown -R $JENKINS_SSH_USER_NAME: /home/$JENKINS_SSH_USER_NAME \
  || error_exit "Failed to chown .ssh directory"
chmod 700 /home/$JENKINS_SSH_USER_NAME/.ssh \
  || error_exit "Failed to chmod .ssh directory"

# Generate SSH host keys
log "Generating SSH host keys..."
mkdir -p /etc/ssh \
  || error_exit "Failed to create /etc/ssh"
ssh-keygen -A \
  || error_exit "ssh-keygen -A failed"

# set variables for secrets
SSH_HOST_KEY_PATH="/etc/ssh/ssh_host_ed25519_key"
SSH_HOST_KEY_PUB_PATH="${SSH_HOST_KEY_PATH}.pub"
JENKINS_KEY_PATH="/tmp/${JENKINS_SSH_USER_NAME}_id_ed25519"
UPDATES_DOWNLOADER_KNOWN_HOSTS_PATH="/tmp/updates_downloader_known_hosts"
KNOWN_HOSTS_ENTRY="${UPDATES_DOWNLOADER_HOST} $(cat ${SSH_HOST_KEY_PUB_PATH})"
JENKINS_USER_AUTHORIZED_KEYS_PATH="/home/$JENKINS_SSH_USER_NAME/.ssh/authorized_keys"

# Generate Jenkins user key-pair
log "Generating $JENKINS_SSH_USER_NAME user key-pair..."
ssh-keygen -t ed25519 -f "$JENKINS_KEY_PATH" -N "" \
  || error_exit "Failed to generate $JENKINS_SSH_USER_NAME user key-pair"

# Generate known_hosts entry for updates-downloader
echo "$KNOWN_HOSTS_ENTRY" > "$UPDATES_DOWNLOADER_KNOWN_HOSTS_PATH" \
  || error_exit "Failed to create known_hosts entry for ${KNOWN_HOSTS_ENTRY}"

# Prepare authorized_keys for Jenkins user
log "Preparing authorized_keys for $JENKINS_SSH_USER_NAME..."
cp "${JENKINS_KEY_PATH}.pub" "$JENKINS_USER_AUTHORIZED_KEYS_PATH" \
  || error_exit "Failed to copy public key to authorized_keys"
chown $JENKINS_SSH_USER_NAME: "$JENKINS_USER_AUTHORIZED_KEYS_PATH" \
  || error_exit "Failed to chown authorized_keys"
chmod 600 "$JENKINS_USER_AUTHORIZED_KEYS_PATH" \
  || error_exit "Failed to chmod authorized_keys"

# Prepare secret definitions: name and --from-file args
log "Preparing secrets definitions..."
secrets=(
  "$JENKINS_PRIVATE_KEY_SECRET --from-file=id_ed25519=${JENKINS_KEY_PATH}"
  "$JENKINS_PUBLIC_KEY_SECRET --from-file=authorized_keys=$JENKINS_USER_AUTHORIZED_KEYS_PATH"
  "$UPDATES_DOWNLOADER_KNOWN_HOSTS_SECRET --from-file=known_hosts=$UPDATES_DOWNLOADER_KNOWN_HOSTS_PATH"
  "$SSH_HOST_KEY_SECRET --from-file=ssh_host_ed25519_key=${SSH_HOST_KEY_PATH} --from-file=ssh_host_ed25519_key.pub=${SSH_HOST_KEY_PUB_PATH}"
)

for secret_def in "${secrets[@]}"; do
  create_secret $secret_def
done

# Clean up
log "Cleaning up temporary files..."
rm -f "$JENKINS_KEY_PATH" "$JENKINS_USER_AUTHORIZED_KEYS_PATH" "$UPDATES_DOWNLOADER_KNOWN_HOSTS_PATH" \
  || log "Warning: cleanup failed"

log "SSH secret generation complete."
