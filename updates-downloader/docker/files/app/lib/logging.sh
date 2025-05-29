#!/bin/sh

LOG_LEVEL=${LOG_LEVEL:-DEBUG}  # Default level

log() {
    local level=$1
    local message=$2
    
    # Level filtering
    case $level in
        DEBUG) [ "$LOG_LEVEL" != "DEBUG" ] && return ;;
        INFO)  [ "$LOG_LEVEL" = "ERROR" ] && return ;;
        *) ;; # Always show ERROR and others
    esac
    
    local script_name=$(basename "${BASH_SOURCE[1]:-$0}")
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] [${script_name}] ${message}"
}

# Helper functions
log_debug() { log "DEBUG" "$1"; }
log_info()  { log "INFO" "$1"; }
log_warn()  { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }

# Export all logging functions
export -f log log_debug log_info log_warn log_error 2>/dev/null || :