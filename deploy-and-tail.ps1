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

# Tail the init_nexus.log log in another new PowerShell window
$logFilePath = '/nexus-data/init_nexus.log'
while ($true) {
    kubectl exec $pod -- sh -c "test -f $logFilePath"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$logFilePath found! Proceeding..." -ForegroundColor Green
        break
    } 
    Write-Host "Waiting for $logFilePath to be created..."
    Start-Sleep -Seconds 2
} 

# Tail the logs in a new PowerShell window
$tailCmd = "kubectl exec $pod -- tail -f $logFilePath"
Write-Host "Tailing $logFilePath log for pod: $pod"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $tailCmd -WindowStyle Normal -WorkingDirectory . -Verb runAs

# Start an interactive bash shell in the container
Write-Host "Starting an interactive bash shell in the pod: $pod"
kubectl exec -it $pod -- bash