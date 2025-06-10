#!/bin/sh
set -e

. /scripts/unprefix_env_vars.sh || error_exit "Failed to load unprefix_env_vars.sh"

# TODO: check what other vars need to move to the chart
# Set variables for secrets
USER_KEY_PATH="/tmp/${SSH_USER_NAME}_id_${SSH_KEY_ALGORITHM}"
KNOWN_HOSTS_PATH="/tmp/known_hosts"
USER_AUTHORIZED_KEYS_PATH="/tmp/authorized_keys"

log() {
  echo "[generate-ssh-secrets][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error_exit() {
  echo "[generate-ssh-secrets][$(date '+%Y-%m-%d %H:%M:%S')][ERROR] $1" >&2
  exit 1
}

create_secret() {
  # $1: entire secret definition string
  local secret_def="$1"
  # Extract the secret name (first word) and the rest of the arguments
  set -- $secret_def
  local secret_name=$1
  shift
  local from_file_args="$@"
  
  log "Secret name: $secret_name, args: $from_file_args"
  log "Deleting old secret $secret_name if it exists..."
  kubectl delete secret "$secret_name" --ignore-not-found \
    || log "Warning: failed to delete $secret_name"
  log "Creating secret $secret_name..."
  kubectl create secret generic "$secret_name" $from_file_args \
    --dry-run=client -o yaml | kubectl apply -f - \
    || error_exit "Failed to create $secret_name"
}

log "Starting..."

log "Unprefixing environment variables..."
unprefix_env_vars ${ENV_PREFIX_2_REMOVE:-} || error_exit "Failed to unprefix environment variables"

# Generate SSH host keys
log "Generating SSH host keys..."
mkdir -p /etc/ssh \
  || error_exit "Failed to create /etc/ssh"
ssh-keygen -t ${SSH_KEY_ALGORITHM} -f /tmp/ssh_host_${SSH_KEY_ALGORITHM}_key -N "" \
  || error_exit "ssh-keygen for host key failed"

# Generate user key-pair
log "Generating $SSH_USER_NAME user key-pair..."
ssh-keygen -t ${SSH_KEY_ALGORITHM} -f "$USER_KEY_PATH" -N "" \
  || error_exit "Failed to generate $SSH_USER_NAME user key-pair"

# Generate known_hosts entry
KNOWN_HOSTS_ENTRY="${TARGET_HOST} $(cat /tmp/ssh_host_${SSH_KEY_ALGORITHM}_key.pub)"
echo "$KNOWN_HOSTS_ENTRY" > "$KNOWN_HOSTS_PATH" \
  || error_exit "Failed to create known_hosts entry"

# Prepare authorized_keys
log "Preparing authorized_keys..."
cp "${USER_KEY_PATH}.pub" "$USER_AUTHORIZED_KEYS_PATH" \
  || error_exit "Failed to copy public key to authorized_keys"

# Prepare secret definitions: name and --from-file args
log "Preparing secrets definitions..."
secrets="
$SSH_PRIVATE_KEY_SECRET --from-file=${SSH_KEY_ALGORITHM}=${USER_KEY_PATH}
$SSH_PUBLIC_KEY_SECRET --from-file=authorized_keys=${USER_AUTHORIZED_KEYS_PATH}
$KNOWN_HOSTS_SECRET --from-file=known_hosts=${KNOWN_HOSTS_PATH}
$SSH_HOST_KEY_SECRET --from-file=ssh_host_${SSH_KEY_ALGORITHM}_key=/tmp/ssh_host_${SSH_KEY_ALGORITHM}_key --from-file=ssh_host_${SSH_KEY_ALGORITHM}_key.pub=/tmp/ssh_host_${SSH_KEY_ALGORITHM}_key.pub
"

echo "$secrets" | while IFS= read -r secret_def; do
  [ -z "$secret_def" ] && continue
  # Debug output to verify what's being processed
  log "Processing secret: $secret_def"
  create_secret "$secret_def"
done

# Clean up
log "Cleaning up temporary files..."
rm -f "$USER_KEY_PATH" "$USER_KEY_PATH.pub" "$KNOWN_HOSTS_PATH" "/tmp/ssh_host_${SSH_KEY_ALGORITHM}_key" "/tmp/ssh_host_${SSH_KEY_ALGORITHM}_key.pub" "$USER_AUTHORIZED_KEYS_PATH" \
  || log "Warning: cleanup failed"

log "SSH secret generation complete."
