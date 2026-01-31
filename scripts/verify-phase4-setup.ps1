# Phase IV - Installation Verification Script
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Phase IV: Installation Verification" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check Docker
Write-Host "1. Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker installed" -ForegroundColor Green
        Write-Host "     Version: $dockerVersion" -ForegroundColor Gray
        
        # Check Docker daemon
        $null = docker ps 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Docker daemon running" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Docker daemon not running" -ForegroundColor Yellow
            Write-Host "     Start Docker Desktop from Start Menu" -ForegroundColor Gray
            $allGood = $false
        }
    } else {
        Write-Host "  ❌ Docker not installed" -ForegroundColor Red
        Write-Host "     Install: choco install docker-desktop -y" -ForegroundColor Gray
        $allGood = $false
    }
} catch {
    Write-Host "  ❌ Docker not found" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""

# Check Minikube
Write-Host "2. Checking Minikube..." -ForegroundColor Yellow
try {
    $minikubeVersion = minikube version --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Minikube installed" -ForegroundColor Green
        Write-Host "     Version: $minikubeVersion" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ Minikube not installed" -ForegroundColor Red
        Write-Host "     Install: choco install minikube -y" -ForegroundColor Gray
        $allGood = $false
    }
} catch {
    Write-Host "  ❌ Minikube not found" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""

# Check kubectl
Write-Host "3. Checking kubectl..." -ForegroundColor Yellow
try {
    $kubectlVersion = kubectl version --client --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ kubectl installed" -ForegroundColor Green
        Write-Host "     Version: $kubectlVersion" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ kubectl not installed" -ForegroundColor Red
        Write-Host "     Install: choco install kubernetes-cli -y" -ForegroundColor Gray
        $allGood = $false
    }
} catch {
    Write-Host "  ❌ kubectl not found" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""

# Check Helm
Write-Host "4. Checking Helm..." -ForegroundColor Yellow
try {
    $helmVersion = helm version --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Helm installed" -ForegroundColor Green
        Write-Host "     Version: $helmVersion" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ Helm not installed" -ForegroundColor Red
        Write-Host "     Install: choco install kubernetes-helm -y" -ForegroundColor Gray
        $allGood = $false
    }
} catch {
    Write-Host "  ❌ Helm not found" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""

# Check Chocolatey
Write-Host "5. Checking Chocolatey..." -ForegroundColor Yellow
try {
    $chocoVersion = choco --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Chocolatey installed" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Chocolatey not installed (needed for easy installation)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Chocolatey not installed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "🎉 All required tools are installed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Ensure Docker Desktop is running" -ForegroundColor White
    Write-Host "  2. Start Minikube: minikube start --cpus=2 --memory=4096" -ForegroundColor White
    Write-Host "  3. Verify cluster: kubectl cluster-info" -ForegroundColor White
} else {
    Write-Host "⚠️  Some tools are missing" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install missing tools, run the commands shown above." -ForegroundColor White
}

Write-Host ""
