// Disable the Jenkins setup wizard on startup (Groovy init script)
import jenkins.model.Jenkins
import java.util.logging.Logger

println(">>> 000-disable-setup-wizard.groovy")

def logger = Logger.getLogger("")
Jenkins.instance.setInstallState(jenkins.install.InstallState.INITIAL_SETUP_COMPLETED)

logger.info("✅ Jenkins setup wizard disabled.")