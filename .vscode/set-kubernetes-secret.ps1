<#
.SYNOPSIS
    Securely creates or deletes a Kubernetes Secret.

.PARAMETER Command
    The operation to perform: 'set' to create/update a secret, 'del' to delete a secret.

.NOTES
    - Requires kubectl.
#>

param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("set", "del")]
    [string]$Command = "set"
)

# Set defaults
$defaultSecretName = "admin-password"
$defaultSecretNamespace = "default"
$defaultSecretKeyName = "password"

# Parameters (via environment variables)
$secretName = $env:SECRET_NAME
if (-not $secretName) { $secretName = $defaultSecretName }
$secretNamespace = $env:SECRET_NAMESPACE
if (-not $secretNamespace) { $secretNamespace = $defaultSecretNamespace }
$secretKeyName = $env:SECRET_KEY_NAME
if (-not $secretKeyName) { $secretKeyName = $defaultSecretKeyName }

if ($Command -eq "del") {
    # Check if secret exists before trying to delete it
    $secretExists = kubectl get secret $secretName -n $secretNamespace --ignore-not-found
    
    if ($secretExists) {
        # Delete the secret
        kubectl delete secret $secretName -n $secretNamespace
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to delete Kubernetes secret"
            exit $LASTEXITCODE
        }
        
        Write-Host "Secret '$secretName' deleted from namespace '$secretNamespace'"
    } else {
        Write-Host "Secret '$secretName' does not exist in namespace '$secretNamespace'"
    }
    
    exit 0
}

$secretValue = $env:SECRET_VALUE
if (-not $secretValue) {
    Write-Error "SECRET_VALUE is not set."
    exit 1
}

# Base64 encode the password (only needed for 'set' command)
$encodedSecretValue = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($secretValue))

# Create YAML for the Kubernetes Secret (only needed for 'set' command)
$secretYaml = @"
apiVersion: v1
kind: Secret
metadata:
  name: ${secretName}
  namespace: ${secretNamespace}
type: Opaque
data:
  ${secretKeyName}: ${encodedSecretValue}
"@

# Apply the secret using kubectl and stdin
$secretYaml | kubectl apply -f -

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create Kubernetes secret"
    exit $LASTEXITCODE
}

Write-Host "Secret '$secretName' created/updated in namespace '$secretNamespace'"