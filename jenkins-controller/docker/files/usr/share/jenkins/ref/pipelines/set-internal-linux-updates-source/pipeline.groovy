// Jenkins pipeline to SSH into internal-linux-service and set YUM repo

def SSH_USER = env.INTERNAL_LINUX_SERVICE_SSH_USER ?: 'jenkins'
def SSH_HOST = env.INTERNAL_LINUX_SERVICE_SSH_HOST ?: 'internal-linux-service'
def SSH_PORT = env.INTERNAL_LINUX_SERVICE_SSH_PORT ?: '2222'
def SSH_KEY_PATH = env.INTERNAL_LINUX_SERVICE_SSH_KEY_PATH ?: '~/.ssh/interface-jenkins-internal-linux_ssh_host_ed25519_key'
def NEXUS_URL = env.NEXUS_URL ?: 'http://nexus:8081'

def repoContent = """[linux-updates]
name=Linux Updates from Nexus Repository
baseurl=${NEXUS_URL}/repository/linux-updates/
enabled=1
gpgcheck=0"""

def sshCmd = """ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} '
mkdir -p /tmp/yum-setup
echo "${repoContent}" > /tmp/yum-setup/linux-updates.repo
cp /tmp/yum-setup/linux-updates.repo /etc/yum.repos.d/
chmod 644 /etc/yum.repos.d/linux-updates.repo
yum clean all
'"""

pipeline {
    agent any
    stages {
        stage('Configure YUM Repository') {
            steps {
                script {
                    echo "Setting up YUM repository on ${SSH_USER}@${SSH_HOST}:${SSH_PORT}"
                    try {
                        sh sshCmd
                    } catch (err) {
                        error "Failed to configure YUM repository: ${err}"
                    }
                }
            }
        }
    }
}