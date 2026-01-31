# ==============================================================================
# Phase IV - Minikube Setup Script (Windows PowerShell)
# ==============================================================================

param(
    [int]$Memory = 4096,
    [int]$Cpus = 4,
    [string]$Driver = "docker",
    [string]$KubernetesVersion = "v1.28.0"
)

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Phase IV - Minikube Setup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "[1/6] Checking Docker..." -ForegroundColor Yellow
try {
    $dockerStatus = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not running"
    }
    Write-Host "  Docker is running" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Minikube is installed
Write-Host "[2/6] Checking Minikube installation..." -ForegroundColor Yellow
try {
    $minikubeVersion = minikube version --short
    Write-Host "  Minikube version: $minikubeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Minikube is not installed." -ForegroundColor Red
    Write-Host "  Install with: winget install Kubernetes.minikube" -ForegroundColor Yellow
    exit 1
}

# Check if kubectl is installed
Write-Host "[3/6] Checking kubectl installation..." -ForegroundColor Yellow
try {
    $kubectlVersion = kubectl version --client --short 2>$null
    Write-Host "  kubectl is installed" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: kubectl is not installed." -ForegroundColor Red
    Write-Host "  Install with: winget install Kubernetes.kubectl" -ForegroundColor Yellow
    exit 1
}

# Check if Helm is installed
Write-Host "[4/6] Checking Helm installation..." -ForegroundColor Yellow
try {
    $helmVersion = helm version --short
    Write-Host "  Helm version: $helmVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Helm is not installed." -ForegroundColor Red
    Write-Host "  Install with: winget install Helm.Helm" -ForegroundColor Yellow
    exit 1
}

# Check Minikube status
Write-Host "[5/6] Checking Minikube status..." -ForegroundColor Yellow
$minikubeStatus = minikube status --format='{{.Host}}' 2>$null

if ($minikubeStatus -eq "Running") {
    Write-Host "  Minikube is already running" -ForegroundColor Green

    # Ask if user wants to restart
    $restart = Read-Host "  Do you want to restart Minikube? (y/N)"
    if ($restart -eq "y" -or $restart -eq "Y") {
        Write-Host "  Stopping Minikube..." -ForegroundColor Yellow
        minikube stop
        Write-Host "  Starting Minikube with new configuration..." -ForegroundColor Yellow
        minikube start --driver=$Driver --memory=$Memory --cpus=$Cpus --kubernetes-version=$KubernetesVersion
    }
} else {
    Write-Host "  Starting Minikube..." -ForegroundColor Yellow
    minikube start --driver=$Driver --memory=$Memory --cpus=$Cpus --kubernetes-version=$KubernetesVersion

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: Failed to start Minikube" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Minikube started successfully" -ForegroundColor Green
}

# Configure kubectl context
Write-Host "[6/6] Configuring kubectl context..." -ForegroundColor Yellow
kubectl config use-context minikube
Write-Host "  kubectl context set to minikube" -ForegroundColor Green

# Display cluster info
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Minikube Setup Complete!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Cluster Information:" -ForegroundColor Yellow
Write-Host "  Minikube IP: $(minikube ip)"
Write-Host "  Kubernetes Version: $KubernetesVersion"
Write-Host "  Memory: ${Memory}MB"
Write-Host "  CPUs: $Cpus"
Write-Host "  Driver: $Driver"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run .\build-images.ps1 to build Docker images"
Write-Host "  2. Run .\deploy.ps1 to deploy the application"
Write-Host ""

# Optional: Configure Docker to use Minikube's daemon
Write-Host "To use Minikube's Docker daemon, run:" -ForegroundColor Yellow
Write-Host '  & minikube -p minikube docker-env --shell powershell | Invoke-Expression' -ForegroundColor White
Write-Host ""
