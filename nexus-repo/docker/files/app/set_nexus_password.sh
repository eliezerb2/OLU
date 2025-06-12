#!/bin/sh
# set_nexus_password: Changes the admin password via Nexus REST API

# Load logging library
. /app/lib/logging.sh

TARGET_HOST="${1:-$TARGET_HOST}"
TARGET_PORT="${2:-$TARGET_PORT}"
ADMIN_USER=${3:-$ADMIN_USER}
ADMIN_PASSWORD_FILE_PATH=/tmp/admin-password-mem/password

curl -X PUT -u $ADMIN_USER:$(cat /nexus-data/admin.password) \
  -H "Content-Type: text/plain" \
  --data "$(cat ${ADMIN_PASSWORD_FILE_PATH})" \
  http://${TARGET_HOST}:${TARGET_PORT}/service/rest/v1/security/users/admin/change-password 
RESULT=$?

# Delete the password file after using it to avoid leaving secrets behind
rm -f ${ADMIN_PASSWORD_FILE_PATH}

if [ "$RESULT" -eq 0 ]; then
  log_info "Admin password updated successfully."
  exit 0
else
  log_error "Failed to update admin password."
  exit 1
fi
