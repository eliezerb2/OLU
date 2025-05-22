pipeline {
    agent any
    environment {
        NEXUS_URL = "${env.NEXUS_URL ?: 'http://nexus-repo:8081'}"
    }
    stages {
        stage('Delete Linux Updates Repo in Nexus') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: env.NEXUS_ADMIN_CREDENTIALS_ID ?: 'nexus-admin',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )
                ]) {
                    script {
                        sh '''
                            curl -v -u "$NEXUS_USER:$NEXUS_PASS" -X DELETE \
                            "$NEXUS_URL/service/rest/v1/repositories/linux-updates"
                        '''
                    }
                }
            }
        }
    }
    post {
        always {
            echo "Repository deletion attempt completed."
        }
        failure {
            echo "Failed to delete repository. Check logs for details."
        }
    }
}
