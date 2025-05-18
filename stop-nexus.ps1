# Stop Nexus Helm release and delete the set-admin-password job pod

# Uninstall the Helm release (ignore errors if not found)
helm uninstall nexus-repo

# Delete any pods created by the set-admin-password job (ignore errors if not found)
$jobPods = kubectl get pods -l job-name=nexus-repo-nexus-admin-password -o jsonpath='{.items[*].metadata.name}'
foreach ($pod in $jobPods -split ' ') {
    if ($pod) {
        kubectl delete pod $pod --ignore-not-found
    }
}

Write-Host "Nexus release and admin password job pods stopped."
