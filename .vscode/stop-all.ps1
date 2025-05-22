# Uninstall all Helm releases in the current namespace
$releases = helm list --short
foreach ($release in $releases) {
    Write-Host "Uninstalling Helm release: $release"
    helm uninstall $release
}

# Delete all pods (if any remain)
$pods = kubectl get pods --no-headers -o custom-columns=":metadata.name"
foreach ($pod in $pods) {
    if ($pod) {
        Write-Host "Deleting pod: $pod"
        kubectl delete pod $pod --ignore-not-found
    }
}

Write-Host "All Helm releases and pods have been stopped."