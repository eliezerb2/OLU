#!/bin/sh
# set_nexus_password: Changes the admin password via Nexus REST API
curl -X PUT -u $ADMIN_USER:$(cat /nexus-data/admin.password) \
  -H "Content-Type: text/plain" \
  --data "$(cat /tmp/admin-password/password)" \
  http://localhost:$NEXUS_PORT/service/rest/v1/security/users/admin/change-password
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Admin password updated successfully."
  exit 0
else
  echo "Failed to update admin password."
  exit 1
fi