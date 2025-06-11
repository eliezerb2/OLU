// Jenkins pipeline to SSH into updates-downloader and run get-updates.sh
// Parameterized for maintainability

def REMOTE_COMMAND = '/app/get-updates.sh'

pipeline {
    agent any
    stages {
        stage('Fetch UBI Updates via SSH') {
            steps {
                script {
                    // Use sh command to extract environment variables starting with UPDATER_
                    def updaterEnvVars = sh(script: "env | grep '^UPDATER_' || echo ''", returnStdout: true).trim()
                    def formattedEnvVars = updaterEnvVars ? updaterEnvVars.replaceAll('\n', ' ') : ''
                    
                    def sshCmd = "ssh -o StrictHostKeyChecking=yes ${env.UPDATES_DOWNLOADER_SSH_JENKINS_USERNAME}@${env.UPDATES_DOWNLOADER_HOST_NAME} '${formattedEnvVars} ${REMOTE_COMMAND}'"
                    def logCmd = "ssh -o StrictHostKeyChecking=yes ${env.UPDATES_DOWNLOADER_SSH_JENKINS_USERNAME}@${env.UPDATES_DOWNLOADER_HOST_NAME} 'tail -n 100 /var/log/get-updates.log'"
                    echo "Running update fetch command on ${env.UPDATES_DOWNLOADER_SSH_JENKINS_USERNAME}@${env.UPDATES_DOWNLOADER_HOST_NAME}:${env.UPDATES_DOWNLOADER_SSH_PORT}"
                    try {
                        sh sshCmd
                    } catch (err) {
                        error "Failed to fetch updates via SSH: ${err}"
                    }
                }
            }
        }
    }
    post {
        failure {
            echo 'Update fetch failed. Fetching remote log for details.'
            script {
                def logCmd = "ssh -o StrictHostKeyChecking=yes ${env.UPDATES_DOWNLOADER_SSH_JENKINS_USERNAME}@${env.UPDATES_DOWNLOADER_HOST_NAME} 'tail -n 100 /var/log/get-updates.log'"
                sh logCmd
            }
        }
    }
}
