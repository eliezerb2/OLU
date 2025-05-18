#!/bin/bash

# Wait for Nexus to start
until curl -s -o /dev/null -w "%{http_code}" http://localhost:${NEXUS_PORT}/nexus/service/rest/v1/status | grep -q "200"; do
  echo "Waiting for Nexus to start..."
  sleep 5
done

# Read the default admin password from the file
DEFAULT_PASSWORD=$(cat /nexus-data/admin.password)

# Use environment variables for new admin credentials
ADMIN_USER=${ADMIN_USER}
NEW_PASSWORD=${NEW_PASSWORD}

# Use the default admin credentials to authenticate and change the password
curl -u admin:$DEFAULT_PASSWORD -X PUT \
  -H "Content-Type: application/json" \
  -d '{"userId": "admin", "password": "'$NEW_PASSWORD'"}' \
  http://localhost:${NEXUS_PORT}/nexus/service/rest/v1/security/users/admin

# Output success message
echo "Admin password updated successfully."

#!/bin/sh
    set -e
    LOG_DIR="/nexus-data/log"
    LOG_FILE="$LOG_DIR/poststart.log"
    mkdir -p "$LOG_DIR"
    # Ensure the log file exists immediately
    touch "$LOG_FILE"
    log() {
      echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
    }
    NEXUS_PORT=${NEXUS_PORT:-8081}
    until curl -s -o /dev/null -w "%{http_code}" http://localhost:${NEXUS_PORT}/service/rest/v1/status | grep -q "200"; do
      log "Waiting for Nexus to start..."
      sleep 5
    done
    log "Nexus is up. Proceeding with password change."
    DEFAULT_PASSWORD=$(cat /nexus-data/admin.password)
    ADMIN_USER=${ADMIN_USER:-admin}
    NEW_PASSWORD=${NEW_PASSWORD:-newpassword}
    # First login with the original password to trigger Nexus password file removal
    LOGIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u admin:$DEFAULT_PASSWORD -X GET http://localhost:${NEXUS_PORT}/service/rest/v1/security/users)
    if [ "$LOGIN_RESPONSE" = "200" ]; then
      log "First login with original password: OK (HTTP 200)"
    else
      log "First login with original password: FAILED (HTTP $LOGIN_RESPONSE)"
    fi
    sleep 2
    # Use printf to avoid shell quoting issues
    JSON_PAYLOAD=$(printf '{"userId":"admin","firstName":"Admin","lastName":"User","emailAddress":"admin@example.com","password":"%s","status":"active","roles":["nx-admin"],"source":"default"}' "$NEW_PASSWORD")
    curl -u admin:$DEFAULT_PASSWORD -X PUT -H "Content-Type: application/json" -d "$JSON_PAYLOAD" http://localhost:${NEXUS_PORT}/service/rest/v1/security/users/admin
    log "Admin password updated successfully."
    # Wait for nexus.log to exist before checking for password change event
    for i in $(seq 1 30); do
      if [ -f /nexus-data/log/nexus.log ]; then
        break
      fi
      log "Waiting for /nexus-data/log/nexus.log to be created... ($i)"
      sleep 2
    done
    # Check nexus.log for password change event
    if grep -q "Changed password for user: admin" /nexus-data/log/nexus.log 2>/dev/null; then
      log "*** PASSWORD CHANGE VERIFIED in nexus.log ***"
    else
      log "!!! PASSWORD CHANGE NOT VERIFIED in nexus.log !!!"
    fi
    exit 0

