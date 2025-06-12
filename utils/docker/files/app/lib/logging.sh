#!/bin/sh

# Log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# Default log level
CURRENT_LOG_LEVEL=${LOG_LEVEL_INFO}

# Get script name function
get_script_name() {
    basename "$0" 2>/dev/null || echo "unknown"
}

# Generic log function
_log() {
    level=$1
    level_name=$2
    message=$3
    output=$4
    
    log_message="[${level_name}][$(date '+%Y-%m-%d %H:%M:%S')][$(get_script_name)] ${message}"
    
    if [ ${CURRENT_LOG_LEVEL} -le ${level} ]; then
        if [ -n "${LOG_FILE_PATH}" ]; then
            # Try to create log file if it doesn't exist
            if [ ! -f "${LOG_FILE_PATH}" ]; then
                touch "${LOG_FILE_PATH}" 2>/dev/null
            fi
            
            # Check if file exists and is writable
            if [ -w "${LOG_FILE_PATH}" ]; then
                if [ "$output" = "stderr" ]; then
                    echo "${log_message}" | tee -a "${LOG_FILE_PATH}" >&2
                else
                    echo "${log_message}" | tee -a "${LOG_FILE_PATH}"
                fi
                return
            fi
        fi
        
        # Fallback to stdout/stderr if log file doesn't exist or can't be created
        if [ "$output" = "stderr" ]; then
            echo "${log_message}" >&2
        else
            echo "${log_message}"
        fi
    fi
}

# Log functions
log_debug() {
    _log ${LOG_LEVEL_DEBUG} "DEBUG" "$1" "stdout"
}

log_info() {
    _log ${LOG_LEVEL_INFO} "INFO" "$1" "stdout"
}

log_warn() {
    _log ${LOG_LEVEL_WARN} "WARN" "$1" "stdout"
}

log_error() {
    _log ${LOG_LEVEL_ERROR} "ERROR" "$1" "stderr"
}