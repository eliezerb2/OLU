#!/bin/sh
set -e

# Load logging library
. /app/lib/logging.sh

/app/init_nexus.sh &
exec /opt/sonatype/nexus/bin/nexus run