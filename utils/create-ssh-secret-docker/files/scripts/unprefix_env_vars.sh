#!/bin/sh

unprefix_env_vars() {
    prefix="$1"
    # If prefix is empty, just return success without modifying anything
    if [ -z "$prefix" ]; then
        echo "No prefix provided, no environment variables will be modified" >&2
        return 0
    fi

    # Create a temporary file
    tmp_file="/tmp/env_vars.$$"
    
    # Use a temporary file to store the environment variables
    if ! env | grep "^${prefix}" > "$tmp_file" 2>/dev/null; then
        echo "Error: Failed to create temporary file or no matching variables found" >&2
        rm -f "$tmp_file" 2>/dev/null
        return 1
    fi
    
    # Check if we found any variables
    if [ ! -s "$tmp_file" ]; then
        echo "Warning: No environment variables with prefix '$prefix' found" >&2
        rm -f "$tmp_file"
        return 0
    fi
    
    # Read variables from the temporary file
    while IFS= read -r line; do
        # Split into name and value
        var_name="${line%%=*}"
        var_value="${line#*=}"
        
        # Remove the prefix
        new_name="${var_name#"$prefix"}"
        
        # Skip if new name is invalid
        if [ -z "$new_name" ] || [ "$new_name" = "$var_name" ]; then
            continue
        fi
        
        # Export the new variable and unset the old one
        if ! eval "export $new_name=\"$var_value\"" 2>/dev/null; then
            echo "Error: Failed to export variable $new_name" >&2
            rm -f "$tmp_file"
            return 1
        fi
        
        if ! unset "$var_name" 2>/dev/null; then
            echo "Warning: Failed to unset variable $var_name" >&2
        fi
        
        echo "Renamed $var_name to $new_name" >&2
    done < "$tmp_file"
    
    # Clean up
    rm -f "$tmp_file"
    return 0
}
