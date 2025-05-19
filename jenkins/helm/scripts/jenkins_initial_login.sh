#!/bin/sh
# jenkins_initial_login: Performs a login to Jenkins to trigger initial setup
LOGIN_URL="http://localhost:${JENKINS_HTTP_PORT}/login"
LOGIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "$ADMIN_USER:$ADMIN_PASSWORD" \
    -X GET "$LOGIN_URL")
if [ "$LOGIN_RESPONSE" = "200" ]; then
  echo "First login with admin credentials: OK (HTTP 200)"
  exit 0
else
  echo "First login with admin credentials: FAILED (HTTP $LOGIN_RESPONSE)"
  exit 1
fi
