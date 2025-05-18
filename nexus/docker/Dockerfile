FROM sonatype/nexus3:latest

# Switch to root for setup operations
USER root

# Use existing writable directories instead of /opt
# ENV SCRIPTS_FOLDER_PARENT_PATH=/nexus-data
ENV SCRIPTS_FOLDER_PATH=/nexus-data/scripts

# Create target directory
RUN mkdir -p ${SCRIPTS_FOLDER_PATH}

# Check directory creation
RUN [ -d "${SCRIPTS_FOLDER_PATH}" ] && echo "✅ Directory created: ${SCRIPTS_FOLDER_PATH}" || (echo "❌ Failed to create directory!" && exit 1)

# Set permissions
RUN chmod 755 ${SCRIPTS_FOLDER_PATH}

# Check permissions
RUN [ "$(stat -c '%a' ${SCRIPTS_FOLDER_PATH})" = "755" ] && \
    echo "✅ Permissions are correctly set to 755" || \
    (echo "❌ Permission check failed!" && exit 1)

# Copy scripts with ownership
# COPY --chown=nexus:nexus ./scripts/check_nexus_ready.sh ${SCRIPTS_FOLDER_PATH}/check_nexus_ready.sh
COPY ./scripts/check_nexus_ready.sh ${SCRIPTS_FOLDER_PATH}/check_nexus_ready.sh

# Check if scripts were copied (i.e., folder is not empty)
RUN if [ "$(ls -A /nexus-data/scripts)" ]; then \
      echo "✅ Scripts copied successfully to /nexus-data/scripts"; \
    else \
      echo "❌ Script copy failed or folder is empty!"; \
      exit 1; \
    fi

# Set ownership
RUN chown nexus:nexus ${SCRIPTS_FOLDER_PATH}/*

# Check ownership
RUN stat -c "%U:%G" ${SCRIPTS_FOLDER_PATH}/* | grep -q "^nexus:nexus$" && \
    echo "✅ Ownership is correctly set to nexus:nexus" || \
    (echo "❌ Ownership check failed!" && exit 1)

# Switch back to nexus user
USER nexus