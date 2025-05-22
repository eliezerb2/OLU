# PowerShell script to build the Docker image using environment variables from the .env file

# Parameters
param(
    [string]$envFilePath,  # Path to the .env file
    [string]$dockerfilePath,  # Path to the Dockerfile directory
    [string]$imageTag  # Docker image tag
)

# Read the .env file and construct --build-arg parameters if envFilePath is provided
$buildArgs = @()
if ($envFilePath) {
    $buildArgs = Get-Content $envFilePath |
        Where-Object { $_.Trim() -ne '' -and $_ -match '=' -and $_ -notmatch '^#' } |
        ForEach-Object {
            $name, $value = $_ -split '=', 2
            "--build-arg $name=$value"
        }
}

# Build the Docker image
# Always use the dockerfilePath as the build context (last argument)
$buildCommand = "docker build $($buildArgs -join ' ') -t $imageTag `"$dockerfilePath`""
Invoke-Expression $buildCommand
