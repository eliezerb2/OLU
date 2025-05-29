// Jenkins pipeline to SSH into updates-downloader and run get-updates.sh
// Parameterized for maintainability

def SSH_USER = env.UPDATES_DOWNLOADER_SSH_USER ?: 'jenkins'
def SSH_HOST = env.UPDATES_DOWNLOADER_SSH_HOST ?: 'updates-downloader'
def SSH_PORT = env.UPDATES_DOWNLOADER_SSH_PORT ?: '2222'
def REMOTE_COMMAND = env.UPDATES_DOWNLOADER_COMMAND ?: '/app/get-updates.sh'
def SSH_KEY_PATH = env.UPDATES_DOWNLOADER_SSH_KEY_PATH ?: '~/.ssh/id_ed25519'

def sshCmd = "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} '${REMOTE_COMMAND}'"

def logCmd = "ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} 'tail -n 100 /var/log/get-updates.log'"

pipeline {
    agent any
    stages {
        stage('Fetch UBI Updates via SSH') {
            steps {
                script {
                    echo "Running update fetch command on ${SSH_USER}@${SSH_HOST}:${SSH_PORT}"
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
                sh logCmd
            }
        }
    }
}
