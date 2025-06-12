#!/bin/sh
set -euo pipefail # Exit immediately if a command exits with a non-zero status

# nexus_initial_login: Performs the first login to Nexus to trigger password file removal
TARGET_HOST="${1:-$TARGET_HOST}"
TARGET_PORT="${2:-$TARGET_PORT}"
ADMIN_USER=${3:-admin} # Default to 'admin' if not explicitly provided

NEXUS_DATA_DIR="/nexus-data" # Standard mount path for Nexus data

echo "Starting initial Nexus login script."

# --- Wait for admin.password file to exist and have content ---
echo "Waiting for ${NEXUS_DATA_DIR}/admin.password to be created and populated..."
FILE_PROBE_COUNT=0
MAX_FILE_PROBES=40 # Try for 40 * 5s = 200 seconds (~3.3 minutes)
FILE_PROBE_PERIOD=5 # Check every 5 seconds

while [ $FILE_PROBE_COUNT -lt "$MAX_FILE_PROBES" ]; do
  FILE_PROBE_COUNT=$((FILE_PROBE_COUNT + 1))
  echo "--- File Probe #$FILE_PROBE_COUNT ---"
  # Check if file exists (-f) AND has a size greater than zero (-s)
  if [ -f "${NEXUS_DATA_DIR}/admin.password" ] && [ -s "${NEXUS_DATA_DIR}/admin.password" ]; then
    echo "admin.password file found and has content."
    break
  else
    echo "admin.password file not found or empty. Retrying in ${FILE_PROBE_PERIOD}s..."
  fi
  sleep "$FILE_PROBE_PERIOD"
done

if [ $FILE_PROBE_COUNT -ge "$MAX_FILE_PROBES" ]; then
  echo "BAD: admin.password file not found or remained empty within the allowed time."
  exit 1 # Fail the script if the file is not generated
fi

# --- Read the initial generated password ---
DEFAULT_PASSWORD=$(cat "${NEXUS_DATA_DIR}/admin.password")
if [ -z "$DEFAULT_PASSWORD" ]; then
    echo "BAD: Read empty password from ${NEXUS_DATA_DIR}/admin.password"
    exit 1
fi
echo "Successfully read initial generated password." # Avoid logging the password itself

# --- Perform initial login ---
LOGIN_URL="http://${TARGET_HOST}:${TARGET_PORT}/service/rest/v1/security/users" # Example Nexus API endpoint

echo "Attempting initial login with Nexus API..."
set +e # Temporarily disable exit on fail for curl command
LOGIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -u "$ADMIN_USER:$DEFAULT_PASSWORD" \
  -X GET "$LOGIN_URL")
CURL_EXIT_CODE=$?
set -e # Re-enable exit on fail

if [ "$CURL_EXIT_CODE" -eq 0 ] && [ "$LOGIN_RESPONSE" = "200" ]; then
  echo "First login with original password: OK (HTTP 200)"
  exit 0
else
  echo "First login with original password: FAILED (HTTP $LOGIN_RESPONSE, Curl Exit Code: $CURL_EXIT_CODE)"
  # For more detailed debugging of 401, print the response body or retry with -v
  echo "Attempting to retrieve full msg from Nexus API:" >&2
  curl -s -u "$ADMIN_USER:$DEFAULT_PASSWORD" -X GET "$LOGIN_URL" >&2
  exit 1
fi