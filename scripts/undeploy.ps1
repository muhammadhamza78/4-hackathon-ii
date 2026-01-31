# ==============================================================================
# Phase IV - Kubernetes Undeploy Script (Windows PowerShell)
# ==============================================================================

param(
    [string]$Namespace = "todo-chatbot",
    [string]$BackendRelease = "todo-backend",
    [string]$FrontendRelease = "todo-frontend",
    [switch]$DeleteNamespace = $false,
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Phase IV - Kubernetes Undeploy" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Confirm deletion
if (-not $Force) {
    Write-Host "This will delete the following resources:" -ForegroundColor Yellow
    Write-Host "  - Helm release: $BackendRelease" -ForegroundColor White
    Write-Host "  - Helm release: $FrontendRelease" -ForegroundColor White
    if ($DeleteNamespace) {
        Write-Host "  - Namespace: $Namespace (and ALL resources within)" -ForegroundColor Red
    }
    Write-Host ""
    $confirm = Read-Host "Are you sure you want to continue? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Check if namespace exists
$namespaceExists = kubectl get namespace $Namespace 2>$null
if (-not $namespaceExists) {
    Write-Host "Namespace '$Namespace' does not exist. Nothing to delete." -ForegroundColor Yellow
    exit 0
}

# Uninstall Frontend
Write-Host "[1/3] Uninstalling Frontend..." -ForegroundColor Yellow
$frontendExists = helm list -n $Namespace | Select-String $FrontendRelease
if ($frontendExists) {
    helm uninstall $FrontendRelease -n $Namespace
    Write-Host "  Frontend uninstalled" -ForegroundColor Green
} else {
    Write-Host "  Frontend release not found, skipping" -ForegroundColor Gray
}

# Uninstall Backend
Write-Host "[2/3] Uninstalling Backend..." -ForegroundColor Yellow
$backendExists = helm list -n $Namespace | Select-String $BackendRelease
if ($backendExists) {
    helm uninstall $BackendRelease -n $Namespace
    Write-Host "  Backend uninstalled" -ForegroundColor Green
} else {
    Write-Host "  Backend release not found, skipping" -ForegroundColor Gray
}

# Delete namespace if requested
if ($DeleteNamespace) {
    Write-Host "[3/3] Deleting namespace..." -ForegroundColor Yellow
    kubectl delete namespace $Namespace
    Write-Host "  Namespace deleted" -ForegroundColor Green
} else {
    Write-Host "[3/3] Keeping namespace '$Namespace'" -ForegroundColor Yellow
    Write-Host "  To delete namespace, run with -DeleteNamespace flag" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Undeploy Complete!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Show remaining resources
if (-not $DeleteNamespace) {
    Write-Host "Remaining resources in namespace '$Namespace':" -ForegroundColor Yellow
    kubectl get all -n $Namespace 2>$null
}
