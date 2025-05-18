#!/bin/sh
# set_nexus_password: Changes the admin password via Nexus REST API
NEXUS_PORT=${NEXUS_PORT:-8081}
ADMIN_USER=${ADMIN_USER:-admin}
DEFAULT_PASSWORD=$(cat /nexus-data/admin.password)
NEW_PASSWORD=${NEW_PASSWORD:-newpassword}
JSON_PAYLOAD=$(printf '{"userId":"admin","firstName":"Admin","lastName":"User","emailAddress":"admin@example.com","password":"%s","status":"active","roles":["nx-admin"],"source":"default"}' "$NEW_PASSWORD")
curl -X PUT -u admin:$DEFAULT_PASSWORD \
  -H "Content-Type: text/plain" \
  --data "$NEW_PASSWORD" \
  http://localhost:$NEXUS_PORT/service/rest/v1/security/users/admin/change-password
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Admin password updated successfully."
  exit 0
else
  echo "Failed to update admin password."
  exit 1
fi
