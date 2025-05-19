param(
    [string]$Prefix
)

if (-not $Prefix) {
    Write-Host "Usage: .vscode/open-pod-shells.ps1 -Prefix <pod-prefix>" -ForegroundColor Yellow
    exit 1
}

# Get all pod names with the given prefix (remove Unix-style line continuation)
$pods = kubectl get pods -o jsonpath='{.items[*].metadata.name}' |
    ForEach-Object { $_ -split ' ' } |
    Where-Object { $_ -like "$Prefix*" }

if (-not $pods) {
    Write-Host "No pods found with prefix '$Prefix'" -ForegroundColor Red
    exit 1
}

foreach ($pod in $pods) {
    Write-Host "Opening shell for pod: $pod"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl exec -it $pod -- bash" -WindowStyle Normal
}
