#!/bin/sh
# set_nexus_password: Changes the admin password via Nexus REST API

TARGET_HOST="${1:-$TARGET_HOST}"
TARGET_PORT="${2:-$TARGET_PORT}"
ADMIN_USER=${3:-admin} # Default to 'admin' if not explicitly provided

curl -X PUT -u $ADMIN_USER:$(cat /nexus-data/admin.password) \
  -H "Content-Type: text/plain" \
  --data "$(cat /tmp/admin-password/password)" \
  http://${TARGET_HOST}:${TARGET_PORT}/service/rest/v1/security/users/admin/change-password 
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Admin password updated successfully."
  exit 0
else
  echo "Failed to update admin password."
  exit 1
fi