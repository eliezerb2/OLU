pipeline {
    agent any  // Ensures it runs on an available executor (better than 'none' if you want it to run somewhere)
    
    environment {
        NEXUS_URL = 'http://nexus-repo:32009'
    }
    
    stages {
        stage('Create Linux Updates Repo in Nexus') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'nexus-admin',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )
                ]) {
                    script {
                        // Use external JSON file for repo config
                        def repoConfigFile = 'linux-updates-repo.json'
                        // Copy the JSON file from workspace if not present
                        if (!fileExists(repoConfigFile)) {
                            error("${repoConfigFile} not found in workspace!")
                        }
                        def curlExitCode = sh(
                            script: """
                                curl -sS -f -u \${NEXUS_USER}:\${NEXUS_PASS} -X POST \
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