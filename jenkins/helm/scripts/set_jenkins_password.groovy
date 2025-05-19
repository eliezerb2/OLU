import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(System.getenv("ADMIN_USER") ?: "admin", System.getenv("ADMIN_PASSWORD") ?: "admin")
instance.setSecurityRealm(hudsonRealm)
instance.save()
