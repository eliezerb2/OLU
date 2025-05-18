#!/bin/sh
# check_nexus_ready: Waits for Nexus to be ready on the REST API
NEXUS_PORT=${NEXUS_PORT:-8081}
TIMEOUT=${CHECK_NEXUS_READY_TIMEOUT:-300} # seconds
SLEEP=${CHECK_NEXUS_READY_SLEEP:-5}
START_TIME=$(date +%s)
while true; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${NEXUS_PORT}/service/rest/v1/status)
  if [ "$STATUS" = "200" ]; then
    echo "Nexus is ready."
    exit 0
  fi
  NOW=$(date +%s)
  ELAPSED=$((NOW - START_TIME))
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "Nexus did not become ready in $TIMEOUT seconds."
    exit 1
  fi
  echo "Waiting for Nexus to be ready... (${ELAPSED}s elapsed, timeout: ${TIMEOUT}s)"
  sleep $SLEEP
done
