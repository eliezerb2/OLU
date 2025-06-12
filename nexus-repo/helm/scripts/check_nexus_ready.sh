#!/bin/sh
set -exuo pipefail # Exit immediately if a command exits with a non-zero status (-e),
                  # treat unset variables as a problem (-u),
                  # and return the exit status of the last command in the pipe that failed (-o pipefail).

# --- Configuration Parameters ---
# These can be passed as environment variables or command-line arguments to the script
# Example: ./monitor_readiness.sh http://localhost 8080 /healthz 5 3 10

TARGET_HOST="${1:-$TARGET_HOST}"
TARGET_PORT="${2:-$TARGET_PORT}"
TARGET_PATH="${3:-$TARGET_PATH}"
PERIOD_SECONDS="${4:-$PERIOD_SECONDS}"
FAILURE_THRESHOLD="${5:-$FAILURE_THRESHOLD}"
INITIAL_DELAY_SECONDS="${6:-$INITIAL_DELAY_SECONDS}"

CONSECUTIVE_FAILURES=0
PROBE_COUNT=0

echo "Starting readiness probe for ${TARGET_HOST}:${TARGET_PORT}${TARGET_PATH}"
echo "Check period: ${PERIOD_SECONDS}s, Failure threshold: ${FAILURE_THRESHOLD} consecutive failures."
echo "Initial delay: ${INITIAL_DELAY_SECONDS}s."

if [ "$INITIAL_DELAY_SECONDS" -gt 0 ]; then
  echo "Waiting for initial delay of ${INITIAL_DELAY_SECONDS} seconds..."
  sleep "$INITIAL_DELAY_SECONDS"
fi

while true; do
  PROBE_COUNT=$((PROBE_COUNT + 1))
  echo "--- Probe #$PROBE_COUNT ---"

  # Temporarily disable 'set -e' so curl's non-zero exit code doesn't terminate the script immediately.
  set +e
  CURL_VERBOSE_OUTPUT=$(curl -sv -o /dev/null -w "%{http_code}\n" -m 10 "http://${TARGET_HOST}:${TARGET_PORT}${TARGET_PATH}" 2>&1)
  CURL_EXIT_CODE=$? # Capture curl's actual exit code
  set -e # Re-enable 'set -e'

  # Extract HTTP_CODE from the last line of the verbose output (ensure -w "%{http_code}\n" for newline)
  HTTP_CODE=$(echo "$CURL_VERBOSE_OUTPUT" | tail -n 1)
  
  # Ensure HTTP_CODE is a 3-digit number, otherwise it implies a connection failure
  if [[ ! "$HTTP_CODE" =~ ^[0-9]{3}$ ]]; then
    HTTP_CODE="000" # Indicates a non-HTTP-response failure (e.g., connection refused)
  fi

  if [ "$CURL_EXIT_CODE" -eq 0 ] && [[ "$HTTP_CODE" =~ ^2 ]]; then
    echo "Probe successful. HTTP Status: ${HTTP_CODE}"
    exit 0 # Exit the script successfully, Nexus is ready
  else
    echo "Probe failed. HTTP Status: ${HTTP_CODE}, Curl Exit Code: ${CURL_EXIT_CODE}"
    echo "--- CURL VERBOSE OUTPUT START ---" >&2
    echo "$CURL_VERBOSE_OUTPUT" >&2 # Print the full verbose output for debugging
    echo "--- CURL VERBOSE OUTPUT END ---" >&2
    
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))

    if [ "$CONSECUTIVE_FAILURES" -ge "$FAILURE_THRESHOLD" ]; then
      echo "BAD: Readiness probe failed ${FAILURE_THRESHOLD} consecutive times. Container is considered NOT READY."
      exit 1 # Indicate overall failure to the Kubernetes lifecycle
    fi
  fi

  sleep "$PERIOD_SECONDS"
done