# ==============================================================================
# Phase IV - Kubernetes Deployment Script (Windows PowerShell)
# ==============================================================================

param(
    [string]$Namespace = "todo-chatbot",
    [string]$BackendRelease = "todo-backend",
    [string]$FrontendRelease = "todo-frontend",
    [string]$ValuesFile = "",
    [switch]$DryRun = $false,
    [switch]$SkipBackend = $false,
    [switch]$SkipFrontend = $false
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Phase IV - Kubernetes Deployment" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "[1/7] Checking prerequisites..." -ForegroundColor Yellow

# Check Minikube
$minikubeStatus = minikube status --format='{{.Host}}' 2>$null
if ($minikubeStatus -ne "Running") {
    Write-Host "  ERROR: Minikube is not running" -ForegroundColor Red
    Write-Host "  Run .\setup-minikube.ps1 first" -ForegroundColor Yellow
    exit 1
}
Write-Host "  Minikube is running" -ForegroundColor Green

# Check kubectl
try {
    kubectl cluster-info | Out-Null
    Write-Host "  kubectl connected to cluster" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: kubectl cannot connect to cluster" -ForegroundColor Red
    exit 1
}

# Check Helm
try {
    helm version | Out-Null
    Write-Host "  Helm is available" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Helm is not installed" -ForegroundColor Red
    exit 1
}

# Check if images exist
Write-Host "[2/7] Checking Docker images..." -ForegroundColor Yellow
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

$backendImage = docker images -q todo-backend:latest 2>$null
$frontendImage = docker images -q todo-frontend:latest 2>$null

if (-not $SkipBackend -and -not $backendImage) {
    Write-Host "  WARNING: todo-backend:latest not found" -ForegroundColor Yellow
    Write-Host "  Run .\build-images.ps1 first" -ForegroundColor Yellow
    $continue = Read-Host "  Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
} else {
    Write-Host "  Backend image found" -ForegroundColor Green
}

if (-not $SkipFrontend -and -not $frontendImage) {
    Write-Host "  WARNING: todo-frontend:latest not found" -ForegroundColor Yellow
    Write-Host "  Run .\build-images.ps1 first" -ForegroundColor Yellow
    $continue = Read-Host "  Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
} else {
    Write-Host "  Frontend image found" -ForegroundColor Green
}

# Create namespace
Write-Host "[3/7] Creating namespace '$Namespace'..." -ForegroundColor Yellow
$namespaceExists = kubectl get namespace $Namespace 2>$null
if (-not $namespaceExists) {
    if ($DryRun) {
        Write-Host "  [DRY-RUN] Would create namespace: $Namespace" -ForegroundColor Magenta
    } else {
        kubectl create namespace $Namespace
        Write-Host "  Namespace created" -ForegroundColor Green
    }
} else {
    Write-Host "  Namespace already exists" -ForegroundColor Green
}

# Load secrets from environment or prompt
Write-Host "[4/7] Configuring secrets..." -ForegroundColor Yellow

# Check for .env file in backend directory
$envFile = "$ProjectRoot\backend\.env"
$secretsArgs = @()

if (Test-Path $envFile) {
    Write-Host "  Loading secrets from $envFile" -ForegroundColor Gray

    $envContent = Get-Content $envFile
    foreach ($line in $envContent) {
        if ($line -match "^DATABASE_URL=(.+)$") {
            $databaseUrl = $matches[1]
            $secretsArgs += "--set", "secrets.databaseUrl=$databaseUrl"
        }
        if ($line -match "^JWT_SECRET_KEY=(.+)$") {
            $jwtSecret = $matches[1]
            $secretsArgs += "--set", "secrets.jwtSecretKey=$jwtSecret"
        }
        if ($line -match "^GROQ_API_KEY=(.+)$") {
            $groqKey = $matches[1]
            $secretsArgs += "--set", "secrets.groqApiKey=$groqKey"
        }
    }
    Write-Host "  Secrets loaded from .env file" -ForegroundColor Green
} else {
    Write-Host "  WARNING: No .env file found at $envFile" -ForegroundColor Yellow
    Write-Host "  Secrets must be configured manually or via values file" -ForegroundColor Yellow
}

# Deploy Backend
if (-not $SkipBackend) {
    Write-Host "[5/7] Deploying Backend..." -ForegroundColor Yellow

    $backendChart = "$ProjectRoot\helm-charts\todo-backend"
    $helmCmd = @("upgrade", "--install", $BackendRelease, $backendChart, "-n", $Namespace)

    if ($ValuesFile -and (Test-Path $ValuesFile)) {
        $helmCmd += "-f", $ValuesFile
    }

    $helmCmd += $secretsArgs
    $helmCmd += "--set", "image.repository=todo-backend"
    $helmCmd += "--set", "image.tag=latest"
    $helmCmd += "--set", "image.pullPolicy=Never"

    if ($DryRun) {
        $helmCmd += "--dry-run"
        Write-Host "  [DRY-RUN] helm $($helmCmd -join ' ')" -ForegroundColor Magenta
    }

    Write-Host "  Running: helm $($helmCmd -join ' ')" -ForegroundColor Gray
    & helm @helmCmd

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: Backend deployment failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Backend deployed successfully" -ForegroundColor Green
} else {
    Write-Host "[5/7] Skipping Backend deployment..." -ForegroundColor Yellow
}

# Deploy Frontend
if (-not $SkipFrontend) {
    Write-Host "[6/7] Deploying Frontend..." -ForegroundColor Yellow

    $frontendChart = "$ProjectRoot\helm-charts\todo-frontend"
    $helmCmd = @("upgrade", "--install", $FrontendRelease, $frontendChart, "-n", $Namespace)

    if ($ValuesFile -and (Test-Path $ValuesFile)) {
        $helmCmd += "-f", $ValuesFile
    }

    # Set backend service URL
    $helmCmd += "--set", "config.apiUrl=http://$BackendRelease-svc:8000"
    $helmCmd += "--set", "image.repository=todo-frontend"
    $helmCmd += "--set", "image.tag=latest"
    $helmCmd += "--set", "image.pullPolicy=Never"

    if ($DryRun) {
        $helmCmd += "--dry-run"
        Write-Host "  [DRY-RUN] helm $($helmCmd -join ' ')" -ForegroundColor Magenta
    }

    Write-Host "  Running: helm $($helmCmd -join ' ')" -ForegroundColor Gray
    & helm @helmCmd

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: Frontend deployment failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Frontend deployed successfully" -ForegroundColor Green
} else {
    Write-Host "[6/7] Skipping Frontend deployment..." -ForegroundColor Yellow
}

# Wait for deployments
Write-Host "[7/7] Waiting for pods to be ready..." -ForegroundColor Yellow

if (-not $DryRun) {
    if (-not $SkipBackend) {
        Write-Host "  Waiting for backend..." -ForegroundColor Gray
        kubectl rollout status deployment/$BackendRelease -n $Namespace --timeout=120s
    }

    if (-not $SkipFrontend) {
        Write-Host "  Waiting for frontend..." -ForegroundColor Gray
        kubectl rollout status deployment/$FrontendRelease -n $Namespace --timeout=120s
    }
}

# Display status
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Deployment Complete!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

if (-not $DryRun) {
    Write-Host "Resources in namespace '$Namespace':" -ForegroundColor Yellow
    kubectl get all -n $Namespace
    Write-Host ""

    # Get access URL
    $minikubeIp = minikube ip
    Write-Host "Access the application:" -ForegroundColor Yellow
    Write-Host "  Frontend: http://${minikubeIp}:30080" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use minikube service:" -ForegroundColor Yellow
    Write-Host "  minikube service $FrontendRelease-svc -n $Namespace" -ForegroundColor White
    Write-Host ""
    Write-Host "To validate deployment, run:" -ForegroundColor Yellow
    Write-Host "  .\validate.ps1" -ForegroundColor White
}
