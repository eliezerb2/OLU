pipeline {
    agent any
    
    environment {
        NEXUS_URL = "${env.NEXUS_URL}"
        REPO_NAME = "linux-updates"
        SSH_USER = "${env.UPDATES_DOWNLOADER_SSH_USER ?: 'jenkins'}"
        SSH_HOST = "${env.UPDATES_DOWNLOADER_SSH_HOST ?: 'updates-downloader'}"
        SSH_PORT = "${env.UPDATES_DOWNLOADER_SSH_PORT ?: '2222'}"
        SSH_KEY_PATH = "${env.UPDATES_DOWNLOADER_SSH_KEY_PATH ?: '~/.ssh/id_ed25519'}"
        REMOTE_UPDATES_DIR = "${env.UPDATER_DOWNLOAD_DIR ?: '/updates'}"
    }
    
    stages {
        stage('Debug Environment') {
            steps {
                script {
                    echo "Debug: SSH_HOST=${SSH_HOST}, SSH_PORT=${SSH_PORT}, SSH_USER=${SSH_USER}"
                    echo "Debug: REMOTE_UPDATES_DIR=${REMOTE_UPDATES_DIR}"
                    
                    // Check if we can connect and list directories
                    sh "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'ls -la / | grep updates'"
                    sh "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'find / -name \"*.rpm\" -type f 2>/dev/null | head -5'"
                }
            }
        }
        
        stage('Upload Updates to Nexus') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${env.NEXUS_ADMIN_CREDENTIALS_ID ?: 'nexus-admin'}",
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )
                ]) {
                    script {
                        def updatesDir = REMOTE_UPDATES_DIR
                        
                        // Check if appstream directory exists
                        def repoDir = sh(
                            script: "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'find ${REMOTE_UPDATES_DIR} -type d -name \"*appstream*\" | head -1'",
                            returnStdout: true
                        ).trim()
                        
                        if (repoDir) {
                            updatesDir = repoDir
                        }
                        
                        // Get list of RPMs to upload
                        def rpmFiles = sh(
                            script: "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'find ${updatesDir} -type f -name \"*.rpm\" | sort'",
                            returnStdout: true
                        ).trim()
                        
                        if (!rpmFiles) {
                            // Try to find RPMs in subdirectories
                            rpmFiles = sh(
                                script: "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'find ${updatesDir} -type f -path \"*/*/*.rpm\" | sort'",
                                returnStdout: true
                            ).trim()
                        }
                        
                        if (!rpmFiles) {
                            error "No RPM files found in ${updatesDir} or its subdirectories"
                        }
                        
                        // Create a temporary directory on the remote server for file transfer
                        sh "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'mkdir -p /tmp/rpm-transfer'"
                        
                        // Upload each RPM file to Nexus
                        rpmFiles.tokenize('\n').each { rpmFile ->
                            def fileName = sh(
                                script: "basename ${rpmFile}",
                                returnStdout: true
                            ).trim()
                            
                            echo "Uploading ${fileName} to Nexus repository ${REPO_NAME}"
                            
                            // Copy the file to a temporary location on the remote server first
                            sh "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'cp ${rpmFile} /tmp/rpm-transfer/${fileName}'"
                            
                            // Use sftp instead of scp
                            sh "sftp -i ${SSH_KEY_PATH} -P ${SSH_PORT} ${SSH_USER}@${SSH_HOST}:/tmp/rpm-transfer/${fileName} ."
                            
                            // Upload to Nexus using the components API for YUM repositories with detailed error output
                            echo "Attempting to upload ${fileName} to Nexus YUM repository"
                            def uploadOutput = sh(
                                script: """
                                    curl -u ${NEXUS_USER}:${NEXUS_PASS} -v -X POST \\
                                    -F "yum.asset=@${fileName}" \\
                                    -F "yum.asset.filename=${fileName}" \\
                                    -F "yum.directory=/" \\
                                    "${NEXUS_URL}/service/rest/v1/components?repository=${REPO_NAME}" 2>&1 || echo "Upload failed"
                                """,
                                returnStdout: true
                            ).trim()
                            
                            echo "Upload response: ${uploadOutput}"
                            
                            // Check if upload was successful
                            def uploadStatus = uploadOutput.contains("Upload failed") ? 1 : 0
                            
                            if (uploadStatus != 0) {
                                error "Failed to upload ${fileName} to Nexus"
                            }
                            
                            // Clean up local copy
                            sh "rm -f ${fileName}"
                            sh "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'rm -f /tmp/rpm-transfer/${fileName}'"
                        }
                        
                        // Clean up the temporary directory
                        sh "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'rmdir /tmp/rpm-transfer'"
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "Successfully uploaded all updates to Nexus repository"
        }
        failure {
            echo "Failed to upload updates to Nexus. Check logs for details."
        }
    }
}