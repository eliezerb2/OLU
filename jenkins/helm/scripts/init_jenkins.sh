#!/bin/sh
# init_jenkins.sh: Run Jenkins automation scripts in order and log output
LOGFILE=/var/jenkins_home/init_jenkins.log

touch "$LOGFILE"

for script in \
  /var/jenkins_home/scripts/check_jenkins_ready.sh \
  /var/jenkins_home/scripts/jenkins_initial_login.sh \
  /var/jenkins_home/scripts/set_jenkins_password.sh
  do
    echo "▶ Running $script" >> "$LOGFILE"
    if ! ($script >> "$LOGFILE" 2>&1); then
      echo "❌ $script failed" >> "$LOGFILE"
      exit 1
    fi
done
# Copy Groovy script for password automation
cp /var/jenkins_home/scripts/set_jenkins_password.groovy /var/jenkins_home/init.groovy.d/set_jenkins_password.groovy
