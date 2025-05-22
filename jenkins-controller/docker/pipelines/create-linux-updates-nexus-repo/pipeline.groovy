pipeline {
    agent any  // Ensures it runs on an available executor (better than 'none' if you want it to run somewhere)
    
    environment {
        NEXUS_URL = "${env.NEXUS_URL ?: 'http://nexus-repo:8081'}"
    }
    
    stages {
        stage('Create Linux Updates Repo in Nexus') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: env.NEXUS_ADMIN_CREDENTIALS_ID ?: 'nexus-admin',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )
                ]) {
                    script {
                        def pipelinesDir = env.PIPELINES_FOLDER_PATH ?: '/usr/share/jenkins/ref/pipelines'
                        // Use external JSON file for repo config
                        def repoConfigFile = "${pipelinesDir}/create-linux-updates-nexus-repo/linux-updates-repo.json"
                        // Debug: check file existence and permissions before curl
                        sh "ls -l ${repoConfigFile} || echo 'File not found or inaccessible'"
                        sh "cat ${repoConfigFile} || echo 'Cannot read file'"
                        // Debug: get full error message from Nexus
                        def curlExitCode = sh(
                            script: """
                                curl -v -u \${NEXUS_USER}:\${NEXUS_PASS} -X POST \
                                -H 'Content-Type: application/json' \
                                --data @${repoConfigFile} \
                                \${NEXUS_URL}/service/rest/v1/repositories/raw/hosted
                            """,
                            returnStatus: true
                        )
                        
                        // Fail if curl failed
                        if (curlExitCode != 0) {
                            error("Failed to create repository (curl exit code: ${curlExitCode})")
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Optional: Log cleanup or notifications
            echo "Repository creation attempt completed."
        }
        failure {
            // Optional: Send failure alerts (Slack, Email, etc.)
            echo "Failed to create repository. Check logs for details."
        }
    }
}