import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import jenkins.model.*
import hudson.util.Secret
import java.util.logging.Logger

final String SCRIPT_NAME = '[015-set-nexus-repo-credentials]'
println(">>> ${SCRIPT_NAME} executed")
def logger = Logger.getLogger("")

def credentials_store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
def credentials_id = System.getenv("NEXUS_ADMIN_CREDENTIALS_ID") ?:"nexus-admin"
def username = System.getenv("NEXUS_ADMIN_USER") ?: "admin"
def password = System.getenv("NEXUS_ADMIN_PASSWORD") ?: "admin"

try {
    if (!com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
            com.cloudbees.plugins.credentials.common.StandardUsernameCredentials.class,
            Jenkins.instance,
            null,
            null
        ).any { it.id == credentials_id }) {

        def c = new UsernamePasswordCredentialsImpl(
            CredentialsScope.GLOBAL,
            credentials_id,
            "Nexus admin user",
            username,
            password
        )
        credentials_store.addCredentials(Domain.global(), c)
        logger.info("${SCRIPT_NAME} Created Jenkins credential: ${credentials_id}")
        println "Created Jenkins credential: ${credentials_id}"
    } else {
        logger.info("${SCRIPT_NAME} Jenkins credential already exists: ${credentials_id}")
        println "Jenkins credential already exists: ${credentials_id}"
    }
} catch (Exception e) {
    logger.severe("${SCRIPT_NAME} ERROR: ${e.message}")
    println ">>> ${SCRIPT_NAME} ERROR: ${e.message}"
}