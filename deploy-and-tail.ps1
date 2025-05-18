# Deploy Nexus Helm chart and tail the log of the running pod
param(
    [string]$ReleaseName,
    [string]$ChartPath,
    [string]$ValuesFile
)

# Deploy or upgrade the Helm release
helm upgrade --install $ReleaseName $ChartPath --values $ValuesFile

# Wait for the pod to be ready and get the pod name
do {
    $pod = kubectl get pods -l app=nexus -o jsonpath='{.items[0].metadata.name}'
    Start-Sleep -Seconds 2
} while (-not $pod -or (kubectl get pod $pod -o jsonpath='{.status.phase}') -ne 'Running')

# Tail the logs in a new PowerShell window
$tailCmd = "kubectl logs -f $pod"
Write-Host "Tailing logs for pod: $pod"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $tailCmd -WindowStyle Normal -WorkingDirectory . -Verb runAs

# Tail the poststart log in another new PowerShell window
$logCmd = @"
`$maxWait = 120
`$waited = 0
while ((-not (kubectl exec $pod -- sh -c 'test -f /nexus-data/log/poststart.log')) -and (`$waited -lt `$maxWait)) {
    Write-Host 'Waiting for /nexus-data/log/poststart.log to be created...'
    Start-Sleep -Seconds 2
    `$waited += 2
}
if (kubectl exec $pod -- sh -c 'test -f /nexus-data/log/poststart.log') {
    kubectl exec $pod -- tail -f /nexus-data/log/poststart.log
} else {
    Write-Host "poststart.log not found after `$maxWait seconds"
}
"@

Write-Host "Tailing poststart log for pod: $pod"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $logCmd -WindowStyle Normal -WorkingDirectory . -Verb runAs

# Start an interactive bash shell in the container
Write-Host "Starting an interactive bash shell in the pod: $pod"
kubectl exec -it $pod -- bash