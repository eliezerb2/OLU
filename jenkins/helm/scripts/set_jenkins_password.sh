#!/bin/sh
# set_jenkins_password: Installs Groovy script to set Jenkins admin password on startup
set -e
GROOVY_DIR="/var/jenkins_home/init.groovy.d"
SCRIPT_SRC="/var/jenkins_home/scripts/set_jenkins_password.groovy"
SCRIPT_DEST="$GROOVY_DIR/set_jenkins_password.groovy"

mkdir -p "$GROOVY_DIR"
cp "$SCRIPT_SRC" "$SCRIPT_DEST"
echo "Groovy admin password script installed to $SCRIPT_DEST"
