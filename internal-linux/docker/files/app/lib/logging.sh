#!/bin/sh

# Log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# Default log level
CURRENT_LOG_LEVEL=${LOG_LEVEL_INFO}

# Log functions
log_debug() {
    if [ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_DEBUG} ]; then
        echo "[DEBUG][$(date '+%Y-%m-%d %H:%M:%S')] $1"
    fi
}

log_info() {
    if [ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_INFO} ]; then
        echo "[INFO][$(date '+%Y-%m-%d %H:%M:%S')] $1"
    fi
}

log_warn() {
    if [ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_WARN} ]; then
        echo "[WARN][$(date '+%Y-%m-%d %H:%M:%S')] $1"
    fi
}

log_error() {
    if [ ${CURRENT_LOG_LEVEL} -le ${LOG_LEVEL_ERROR} ]; then
        echo "[ERROR][$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
    fi
}