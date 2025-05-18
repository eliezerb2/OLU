#!/bin/sh
# nexus_initial_login: Performs the first login to Nexus to trigger password file removal
NEXUS_PORT=${NEXUS_PORT:-8081}
ADMIN_USER=${ADMIN_USER:-admin}
DEFAULT_PASSWORD=$(cat /nexus-data/admin.password)
LOGIN_URL="http://localhost:${NEXUS_PORT}/service/rest/v1/security/users"
LOGIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "$ADMIN_USER:$DEFAULT_PASSWORD" \
    -X GET "$LOGIN_URL")
if [ "$LOGIN_RESPONSE" = "200" ]; then
  echo "First login with original password: OK (HTTP 200)"
  exit 0
else
  echo "First login with original password: FAILED (HTTP $LOGIN_RESPONSE)"
  exit 1
fi
