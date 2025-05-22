import jenkins.model.*
import hudson.security.*
import java.util.logging.Logger

def logger = Logger.getLogger("")
def instance = Jenkins.getInstance()

def env = System.getenv()
def adminUsername = env['ADMIN_USER']
def adminPassword = env['ADMIN_PASSWORD']

if (!adminUsername || !adminPassword) {
    logger.warning("ADMIN_USER or ADMIN_PASSWORD environment variables are not set. Skipping admin user setup.")
    return
}

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
instance.setSecurityRealm(hudsonRealm)

// Simple strategy: logged-in users have full control, no anonymous read
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()

logger.info("✅ Admin user '${adminUsername}' configured.")
