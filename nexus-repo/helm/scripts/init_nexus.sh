#!/bin/sh
set -e

for script in \
  /scripts/check_nexus_ready.sh \
  /scripts/nexus_initial_login.sh \
  /scripts/set_nexus_password.sh
do
  echo "✅ Running $script"
  # Capture stdout and stderr of the called script
  if ! "$script" 2>&1; then
    echo "❌ $script failed"
    exit 1
  fi
done