#!/bin/sh
# init_jenkins.sh: Run Jenkins automation scripts in order and log output
LOGFILE=/var/jenkins_home/init_jenkins.log

touch "$LOGFILE"

# Copy Groovy script for password automation
cp /var/jenkins_home/scripts/set_jenkins_password.groovy /var/jenkins_home/init.groovy.d/set_jenkins_password.groovy
