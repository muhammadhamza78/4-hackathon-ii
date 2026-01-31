# ==============================================================================
# Phase IV - Docker Image Build Script (Windows PowerShell)
# ==============================================================================

param(
    [switch]$UseMinikubeDocker = $true,
    [string]$BackendTag = "latest",
    [string]$FrontendTag = "latest",
    [string]$BackendOnly = $false,
    [string]$FrontendOnly = $false
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Phase IV - Docker Image Build" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "[1/5] Checking Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "  Docker is running" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Docker is not running" -ForegroundColor Red
    exit 1
}

# Configure Minikube Docker environment if requested
if ($UseMinikubeDocker) {
    Write-Host "[2/5] Configuring Minikube Docker environment..." -ForegroundColor Yellow
    try {
        $minikubeStatus = minikube status --format='{{.Host}}' 2>$null
        if ($minikubeStatus -ne "Running") {
            Write-Host "  ERROR: Minikube is not running. Start it first with setup-minikube.ps1" -ForegroundColor Red
            exit 1
        }
        & minikube -p minikube docker-env --shell powershell | Invoke-Expression
        Write-Host "  Using Minikube's Docker daemon" -ForegroundColor Green
    } catch {
        Write-Host "  WARNING: Could not configure Minikube Docker. Using local Docker." -ForegroundColor Yellow
    }
} else {
    Write-Host "[2/5] Using local Docker daemon..." -ForegroundColor Yellow
}

# Build Backend Image
if (-not $FrontendOnly) {
    Write-Host "[3/5] Building Backend Image..." -ForegroundColor Yellow
    Write-Host "  Context: $ProjectRoot\backend" -ForegroundColor Gray
    Write-Host "  Dockerfile: $ProjectRoot\docker\backend\Dockerfile" -ForegroundColor Gray
    Write-Host "  Tag: todo-backend:$BackendTag" -ForegroundColor Gray
    Write-Host ""

    Push-Location $ProjectRoot\backend
    try {
        docker build `
            -f "$ProjectRoot\docker\backend\Dockerfile" `
            -t "todo-backend:$BackendTag" `
            .

        if ($LASTEXITCODE -ne 0) {
            throw "Backend build failed"
        }
        Write-Host "  Backend image built successfully" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: Failed to build backend image" -ForegroundColor Red
        Write-Host "  $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Write-Host "[3/5] Skipping Backend Image (--FrontendOnly specified)..." -ForegroundColor Yellow
}

# Build Frontend Image
if (-not $BackendOnly) {
    Write-Host "[4/5] Building Frontend Image..." -ForegroundColor Yellow
    Write-Host "  Context: $ProjectRoot\frontend" -ForegroundColor Gray
    Write-Host "  Dockerfile: $ProjectRoot\docker\frontend\Dockerfile" -ForegroundColor Gray
    Write-Host "  Tag: todo-frontend:$FrontendTag" -ForegroundColor Gray
    Write-Host ""

    Push-Location $ProjectRoot\frontend
    try {
        docker build `
            -f "$ProjectRoot\docker\frontend\Dockerfile" `
            -t "todo-frontend:$FrontendTag" `
            --build-arg NEXT_PUBLIC_API_URL=http://todo-backend-svc:8000 `
            .

        if ($LASTEXITCODE -ne 0) {
            throw "Frontend build failed"
        }
        Write-Host "  Frontend image built successfully" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: Failed to build frontend image" -ForegroundColor Red
        Write-Host "  $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Write-Host "[4/5] Skipping Frontend Image (--BackendOnly specified)..." -ForegroundColor Yellow
}

# Verify Images
Write-Host "[5/5] Verifying built images..." -ForegroundColor Yellow
Write-Host ""
docker images | Select-String -Pattern "todo-backend|todo-frontend|REPOSITORY"
Write-Host ""

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Image Build Complete!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Built Images:" -ForegroundColor Yellow
if (-not $FrontendOnly) {
    Write-Host "  - todo-backend:$BackendTag"
}
if (-not $BackendOnly) {
    Write-Host "  - todo-frontend:$FrontendTag"
}
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  Run .\deploy.ps1 to deploy the application to Minikube"
Write-Host ""

# If not using Minikube Docker, remind to load images
if (-not $UseMinikubeDocker) {
    Write-Host "NOTE: Images were built with local Docker." -ForegroundColor Yellow
    Write-Host "To load into Minikube, run:" -ForegroundColor Yellow
    Write-Host "  minikube image load todo-backend:$BackendTag"
    Write-Host "  minikube image load todo-frontend:$FrontendTag"
    Write-Host ""
}
