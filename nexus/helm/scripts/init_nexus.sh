#!/bin/sh
set -e
LOGFILE=/nexus-data/init_nexus.log

for script in \
  /scripts/check_nexus_ready.sh \
  /scripts/nexus_initial_login.sh \
  /scripts/set_nexus_password.sh
do
  echo "▶ Running $script" >> "$LOGFILE"
  if ! ($script >> "$LOGFILE" 2>&1); then
    echo "❌ $script failed" >> "$LOGFILE"
    exit 1
  fi
done
