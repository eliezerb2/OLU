#!/bin/sh
# check_jenkins_ready: Waits for Jenkins to be ready on the REST API
JENKINS_HTTP_PORT=${JENKINS_HTTP_PORT:-8080}
TIMEOUT=${CHECK_JENKINS_READY_TIMEOUT:-300} # seconds
SLEEP=${CHECK_JENKINS_READY_SLEEP:-5}
START_TIME=$(date +%s)
while true; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" -L http://localhost:${JENKINS_HTTP_PORT}/login)
  if [ "$STATUS" = "200" ]; then
    echo "Jenkins is ready (HTTP $STATUS)."
    exit 0
  fi
  NOW=$(date +%s)
  ELAPSED=$((NOW - START_TIME))
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "Jenkins did not become ready in $TIMEOUT seconds. Last status: $STATUS."
    exit 1
  fi
  echo "Waiting for Jenkins to be ready... (${ELAPSED}s elapsed, timeout: ${TIMEOUT}s, last status: $STATUS)"
  sleep $SLEEP
done
