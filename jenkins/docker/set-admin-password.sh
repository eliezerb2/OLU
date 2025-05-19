#!/bin/bash
# Set Jenkins admin password on first startup
# Usage: set-admin-password.sh <password>

JENKINS_HOME="/var/jenkins_home"
ADMIN_PASSWORD="${JENKINS_ADMIN_PASSWORD:-admin}"

# Wait for Jenkins to initialize the user database
while [ ! -f "$JENKINS_HOME/users/admin/config.xml" ]; do
  echo "Waiting for Jenkins admin user config to be created..."
  sleep 2
done

# Use xmlstarlet to update the password (requires xmlstarlet in the image)
if command -v xmlstarlet >/dev/null 2>&1; then
  HASHED_PASSWORD=$(docker run --rm jenkins/jenkins:lts bash -c "jenkins-plugin-cli --hash-password $ADMIN_PASSWORD" | tail -n1)
  xmlstarlet ed -L -u "/user/properties/hudson.security.HudsonPrivateSecurityRealm_-Details/passwordHash" -v "$HASHED_PASSWORD" "$JENKINS_HOME/users/admin/config.xml"
  echo "Admin password updated."
else
  echo "xmlstarlet not found. Please install xmlstarlet in the Jenkins image."
fi
