# Stop the updates-downloader Helm release
helm uninstall updates-downloader

# Delete all jobs with prefix 'updates-downloader'
$jobs = kubectl get jobs -o jsonpath='{.items[*].metadata.name}' | ForEach-Object { $_ -split ' ' } | Where-Object { $_ -like 'updates-downloader*' }
foreach ($job in $jobs) {
    if ($job) {
        Write-Host "Deleting job: $job"
        kubectl delete job $job --ignore-not-found
    }
}

# Delete ServiceAccount, Role, and RoleBinding for ssh-keygen
kubectl delete serviceaccount ssh-keygen --ignore-not-found
kubectl delete role ssh-keygen --ignore-not-found
kubectl delete rolebinding ssh-keygen --ignore-not-found

Write-Host "updates-downloader release, jobs, and RBAC resources stopped."
