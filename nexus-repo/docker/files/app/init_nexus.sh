#!/bin/sh
set -e

# Load logging library
. /app/lib/logging.sh

# Ensure LOG_FILE_PATH is set for the logging library to use it
# You should have this defined in your environment or explicitly in init_nexus.sh
# Example: export LOG_FILE_PATH="/var/log/init_nexus.log"

for script in \
  /app/check_nexus_ready.sh \
  /app/nexus_initial_login.sh \
  /app/set_nexus_password.sh
do
  log_info "✅ Running $script"
  # Capture stdout and stderr of the called script and send it to both console and log file
  if ! "$script" 2>&1 | tee -a "${LOG_FILE_PATH}"; then
    # The detailed error from the child script would have already been teed to the log file.
    # This line confirms the child script's overall failure to the main log.
    log_error "❌ $script failed. Check the log file for details."
    exit 1
  fi
done

log_info "All Nexus initialization scripts completed successfully."