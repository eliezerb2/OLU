# Deploy Helm chart and tail the log of the running pod
param(
    [string]$ReleaseName,
    [string]$ChartPath,
    [string]$ValuesFile,
    [string]$AppLabel,
    [string]$LogFilePath
)

Write-Host "[deploy-and-tail.ps1] Parameters:" -ForegroundColor Cyan
Write-Host "  ReleaseName: $ReleaseName" -ForegroundColor Cyan
Write-Host "  ChartPath: $ChartPath" -ForegroundColor Cyan
Write-Host "  ValuesFile: $ValuesFile" -ForegroundColor Cyan
Write-Host "  AppLabel: $AppLabel" -ForegroundColor Cyan
Write-Host "  LogFilePath: $LogFilePath" -ForegroundColor Cyan

if (-not $ReleaseName -or -not $ChartPath -or -not $ValuesFile -or -not $AppLabel) {
    Write-Host "Usage: .vscode/deploy-and-tail.ps1 -ReleaseName <name> -ChartPath <path> -ValuesFile <file1> <file2> ... -AppLabel <label> [-LogFilePath <path>]" -ForegroundColor Yellow
    exit 1
}

# Verify that each values file exists and build the --values arguments for Helm
$ValuesFilesarray = $ValuesFile -split ","
$valuesArgs = @()
foreach ($vf in $ValuesFilesarray) {
    if (-not (Test-Path $vf)) {
        Write-Host "ERROR: Values file not found: $vf" -ForegroundColor Red
        exit 2
    }
    $valuesArgs += @("--values", $vf)
}
Write-Host "Values files: $valuesArgs" -ForegroundColor Cyan

# Deploy or upgrade the Helm release
helm upgrade --install $ReleaseName $ChartPath $valuesArgs

# Wait for the pod to be ready and get the pod name
$pod = $null

do {
    $pod = kubectl get pods -l app=$AppLabel -o jsonpath='{.items[0].metadata.name}'
    Start-Sleep -Seconds 2
} while (-not $pod -or (kubectl get pod $pod -o jsonpath='{.status.phase}') -ne 'Running')

# Tail the logs in a new PowerShell window
$tailCmd = "kubectl logs -f $pod"
Write-Host "Tailing logs for pod: $pod"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $tailCmd -WindowStyle Normal -WorkingDirectory . -Verb runAs

# Only tail the init log if LogFilePath was provided
if ($LogFilePath) {
    # Tail the init log in another new PowerShell window (if present)
    $found = $false
    for ($i = 0; $i -lt 10; $i++) {
        kubectl exec $pod -- sh -c "test -f $LogFilePath"
        if ($LASTEXITCODE -eq 0) {
            $found = $true
            break
        }
        Start-Sleep -Seconds 2
    }

    if (-not $found) {
        Write-Host "Log file not found at $LogFilePath after waiting. Exiting..." -ForegroundColor Red
        exit 1
    }

    while ($true) {
        kubectl exec $pod -- sh -c "test -f $LogFilePath"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$LogFilePath found! Proceeding..." -ForegroundColor Green
            break
        }
        Write-Host "Waiting for $LogFilePath to be created..."
        Start-Sleep -Seconds 2
    }

    $tailCmd = "kubectl exec $pod -- tail -f $LogFilePath"
    Write-Host "Tailing $LogFilePath log for pod: $pod"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $tailCmd -WindowStyle Normal -WorkingDirectory . -Verb runAs
}

# Start an interactive bash shell in the container
Write-Host "Starting an interactive bash shell in the pod: $pod"
kubectl exec -it $pod -- bash