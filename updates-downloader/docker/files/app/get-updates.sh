#!/bin/bash
# get-updates.sh: Fetch Rocky Linux updates from a public mirror
set -euo pipefail

# All required environment variables must be set by the environment (Helm values)
# No default assignments here

mkdir -p "$UPDATER_DOWNLOAD_DIR"

{
    echo "[INFO] Fetching Rocky Linux updates from: $UPDATER_ROCKY_REPO_URL"
    echo "[INFO] Download directory: $UPDATER_DOWNLOAD_DIR"
    echo "[INFO] Architecture: $UPDATER_ARCH"
    echo "[INFO] Timeout: $UPDATER_TIMEOUT_SECONDS seconds"
    echo "[INFO] Start time: $(date)"

    # Print enabled repos for debugging
    echo "[DEBUG] Enabled repos:"
    dnf repolist enabled || true

    # Use reposync to download all RPMs from the Rocky Linux AppStream repo, restricting by arch and downloading comps, with a timeout
    if command -v reposync &>/dev/null; then
        timeout "$UPDATER_TIMEOUT_SECONDS" \
        reposync --repoid="$UPDATER_ROCKY_REPO_ID" --download-path="$UPDATER_DOWNLOAD_DIR" --download-metadata --newest-only --downloadcomps --arch="$UPDATER_ARCH" || true
    else
        echo "[ERROR] reposync not found. Please install yum-utils or dnf-utils."
        exit 1
    fi

    echo "[INFO] Update fetch complete."
    echo "[INFO] End time: $(date)"
} | tee -a "$UPDATER_LOG_FILE"
