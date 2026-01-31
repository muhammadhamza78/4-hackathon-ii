# ==============================================================================
# Phase IV - Deployment Validation Script (Windows PowerShell)
# ==============================================================================

param(
    [string]$Namespace = "todo-chatbot",
    [string]$BackendRelease = "todo-backend",
    [string]$FrontendRelease = "todo-frontend",
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

$totalTests = 0
$passedTests = 0
$failedTests = 0

function Test-Check {
    param(
        [string]$Name,
        [scriptblock]$Test
    )

    $script:totalTests++
    Write-Host "  Testing: $Name... " -NoNewline

    try {
        $result = & $Test
        if ($result) {
            Write-Host "PASS" -ForegroundColor Green
            $script:passedTests++
            return $true
        } else {
            Write-Host "FAIL" -ForegroundColor Red
            $script:failedTests++
            return $false
        }
    } catch {
        Write-Host "FAIL" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "    Error: $_" -ForegroundColor Red
        }
        $script:failedTests++
        return $false
    }
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Phase IV - Deployment Validation" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Infrastructure Checks
Write-Host "[1/5] Infrastructure Checks" -ForegroundColor Yellow

Test-Check "Minikube is running" {
    $status = minikube status --format='{{.Host}}' 2>$null
    $status -eq "Running"
}

Test-Check "kubectl can connect to cluster" {
    $result = kubectl cluster-info 2>$null
    $LASTEXITCODE -eq 0
}

Test-Check "Namespace exists" {
    $ns = kubectl get namespace $Namespace -o name 2>$null
    $ns -eq "namespace/$Namespace"
}

# 2. Pod Status Checks
Write-Host ""
Write-Host "[2/5] Pod Status Checks" -ForegroundColor Yellow

Test-Check "Backend pods are running" {
    $pods = kubectl get pods -n $Namespace -l "app.kubernetes.io/name=todo-backend" -o jsonpath='{.items[*].status.phase}' 2>$null
    $pods -match "Running"
}

Test-Check "Frontend pods are running" {
    $pods = kubectl get pods -n $Namespace -l "app.kubernetes.io/name=todo-frontend" -o jsonpath='{.items[*].status.phase}' 2>$null
    $pods -match "Running"
}

Test-Check "All pods are ready" {
    $notReady = kubectl get pods -n $Namespace -o jsonpath='{.items[?(@.status.containerStatuses[0].ready==false)].metadata.name}' 2>$null
    [string]::IsNullOrEmpty($notReady)
}

# 3. Service Checks
Write-Host ""
Write-Host "[3/5] Service Checks" -ForegroundColor Yellow

Test-Check "Backend service exists" {
    $svc = kubectl get svc "$BackendRelease-svc" -n $Namespace -o name 2>$null
    $svc -eq "service/$BackendRelease-svc"
}

Test-Check "Frontend service exists" {
    $svc = kubectl get svc "$FrontendRelease-svc" -n $Namespace -o name 2>$null
    $svc -eq "service/$FrontendRelease-svc"
}

Test-Check "Frontend NodePort is configured" {
    $nodePort = kubectl get svc "$FrontendRelease-svc" -n $Namespace -o jsonpath='{.spec.ports[0].nodePort}' 2>$null
    $nodePort -eq "30080"
}

# 4. Health Endpoint Checks
Write-Host ""
Write-Host "[4/5] Health Endpoint Checks" -ForegroundColor Yellow

# Port forward to test health endpoints
$backendPod = kubectl get pods -n $Namespace -l "app.kubernetes.io/name=todo-backend" -o jsonpath='{.items[0].metadata.name}' 2>$null

Test-Check "Backend health endpoint responds" {
    if ($backendPod) {
        $health = kubectl exec $backendPod -n $Namespace -- curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>$null
        $health -eq "200"
    } else {
        $false
    }
}

Test-Check "Backend API docs accessible" {
    if ($backendPod) {
        $docs = kubectl exec $backendPod -n $Namespace -- curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/docs 2>$null
        $docs -eq "200"
    } else {
        $false
    }
}

$frontendPod = kubectl get pods -n $Namespace -l "app.kubernetes.io/name=todo-frontend" -o jsonpath='{.items[0].metadata.name}' 2>$null

Test-Check "Frontend responds" {
    if ($frontendPod) {
        $response = kubectl exec $frontendPod -n $Namespace -- wget -q -O /dev/null --spider http://localhost:3000/ 2>&1
        $LASTEXITCODE -eq 0
    } else {
        $false
    }
}

# 5. Configuration Checks
Write-Host ""
Write-Host "[5/5] Configuration Checks" -ForegroundColor Yellow

Test-Check "Backend ConfigMap exists" {
    $cm = kubectl get configmap "$BackendRelease-config" -n $Namespace -o name 2>$null
    $cm -eq "configmap/$BackendRelease-config"
}

Test-Check "Backend Secrets exist" {
    $secret = kubectl get secret "$BackendRelease-secrets" -n $Namespace -o name 2>$null
    $secret -eq "secret/$BackendRelease-secrets"
}

Test-Check "Frontend ConfigMap exists" {
    $cm = kubectl get configmap "$FrontendRelease-config" -n $Namespace -o name 2>$null
    $cm -eq "configmap/$FrontendRelease-config"
}

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Validation Summary" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Total Tests: $totalTests"
Write-Host "  Passed: $passedTests" -ForegroundColor Green
Write-Host "  Failed: $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($failedTests -eq 0) {
    Write-Host "All validations passed!" -ForegroundColor Green
    Write-Host ""

    # Show access information
    $minikubeIp = minikube ip
    Write-Host "Access the application:" -ForegroundColor Yellow
    Write-Host "  Frontend URL: http://${minikubeIp}:30080" -ForegroundColor White
    Write-Host "  Backend API:  http://${minikubeIp}:30080/api (via frontend proxy)" -ForegroundColor White
    Write-Host ""
    Write-Host "Or run: minikube service $FrontendRelease-svc -n $Namespace" -ForegroundColor Gray

    exit 0
} else {
    Write-Host "Some validations failed. Check the output above for details." -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting commands:" -ForegroundColor Yellow
    Write-Host "  kubectl get pods -n $Namespace"
    Write-Host "  kubectl describe pods -n $Namespace"
    Write-Host "  kubectl logs -l app.kubernetes.io/name=todo-backend -n $Namespace"
    Write-Host "  kubectl logs -l app.kubernetes.io/name=todo-frontend -n $Namespace"

    exit 1
}
