// Jenkins pipeline to trigger updates-downloader pod to fetch UBI updates from a public source
// Parameterized for maintainability

def POD_LABEL = env.UPDATES_DOWNLOADER_LABEL ?: env.UPDATER_POD_LABEL ?: 'app=updates-downloader'
def NAMESPACE = env.UPDATES_DOWNLOADER_NAMESPACE ?: env.UPDATER_NAMESPACE ?: 'default'
def CONTAINER_NAME = env.UPDATES_DOWNLOADER_CONTAINER ?: env.UPDATER_CONTAINER_NAME ?: 'updates-downloader'
def FETCH_COMMAND = env.UPDATES_DOWNLOADER_COMMAND ?: env.UPDATER_FETCH_COMMAND ?: '/app/get-updates.sh'

def getPodName(label, namespace) {
    def podName = sh(
        script: "kubectl get pods -n ${namespace} -l ${label} -o jsonpath='{.items[0].metadata.name}'",
        returnStdout: true
    ).trim()
    if (!podName) {
        error "No pod found with label ${label} in namespace ${namespace}"
    }
    return podName
}

pipeline {
    agent any
    stages {
        stage('Fetch UBI Updates') {
            steps {
                script {
                    echo "Locating updates-downloader pod..."
                    def podName = getPodName(POD_LABEL, NAMESPACE)
                    echo "Found pod: ${podName}"
                    echo "Running update fetch command: ${FETCH_COMMAND}"
                    try {
                        sh "kubectl exec -n ${NAMESPACE} ${podName} -c ${CONTAINER_NAME} -- ${FETCH_COMMAND}"
                    } catch (err) {
                        error "Failed to fetch updates: ${err}"
                    }
                }
            }
        }
    }
    post {
        failure {
            echo 'Update fetch failed. Check pod logs for details.'
            script {
                def podName = getPodName(POD_LABEL, NAMESPACE)
                sh "kubectl logs -n ${NAMESPACE} ${podName} -c ${CONTAINER_NAME} --tail=100 || true"
            }
        }
    }
}
