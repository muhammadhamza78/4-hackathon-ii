# Phase IV - Deployment Guide

This guide provides step-by-step instructions for deploying the Todo Chatbot application on a local Kubernetes cluster using Minikube.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Detailed Setup](#detailed-setup)
4. [Building Docker Images](#building-docker-images)
5. [Deploying with Helm](#deploying-with-helm)
6. [Accessing the Application](#accessing-the-application)
7. [Configuration](#configuration)
8. [Upgrading](#upgrading)
9. [Uninstalling](#uninstalling)

---

## Prerequisites

### Required Software

| Tool | Version | Installation |
|------|---------|--------------|
| Docker Desktop | Latest | [Download](https://www.docker.com/products/docker-desktop) |
| Minikube | v1.32+ | `winget install Kubernetes.minikube` |
| kubectl | v1.28+ | `winget install Kubernetes.kubectl` |
| Helm | v3.13+ | `winget install Helm.Helm` |

### System Requirements

- **RAM:** Minimum 8GB (4GB allocated to Minikube)
- **CPU:** Minimum 4 cores (2 allocated to Minikube)
- **Disk:** 20GB free space
- **Network:** Internet access for external APIs

### Verify Installation

```powershell
# Check Docker
docker --version

# Check Minikube
minikube version

# Check kubectl
kubectl version --client

# Check Helm
helm version
```

---

## Quick Start

For a quick deployment, run these commands in order:

```powershell
# 1. Setup Minikube
.\scripts\setup-minikube.ps1

# 2. Build Docker images
.\scripts\build-images.ps1

# 3. Deploy to Kubernetes
.\scripts\deploy.ps1

# 4. Validate deployment
.\scripts\validate.ps1
```

---

## Detailed Setup

### Step 1: Start Minikube

```powershell
# Start with default settings (4GB RAM, 4 CPUs)
.\scripts\setup-minikube.ps1

# Or customize resources
.\scripts\setup-minikube.ps1 -Memory 8192 -Cpus 4
```

**Manual start:**

```powershell
minikube start --driver=docker --memory=4096 --cpus=4 --kubernetes-version=v1.28.0
```

### Step 2: Configure Docker Environment

To build images directly in Minikube's Docker daemon:

```powershell
# PowerShell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Bash (WSL/Linux/Mac)
eval $(minikube docker-env)
```

### Step 3: Verify Cluster

```powershell
# Check cluster status
minikube status

# Check nodes
kubectl get nodes

# Check cluster info
kubectl cluster-info
```

---

## Building Docker Images

### Using the Build Script

```powershell
# Build both images
.\scripts\build-images.ps1

# Build only backend
.\scripts\build-images.ps1 -BackendOnly

# Build only frontend
.\scripts\build-images.ps1 -FrontendOnly

# Use local Docker (not Minikube's)
.\scripts\build-images.ps1 -UseMinikubeDocker:$false
```

### Manual Build

```powershell
# Configure Minikube Docker
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Build backend
docker build -f docker/backend/Dockerfile -t todo-backend:latest ./backend

# Build frontend
docker build -f docker/frontend/Dockerfile -t todo-frontend:latest ./frontend --build-arg NEXT_PUBLIC_API_URL=http://todo-backend-svc:8000

# Verify images
docker images | Select-String "todo"
```

### Loading Pre-built Images

If you built images with local Docker:

```powershell
minikube image load todo-backend:latest
minikube image load todo-frontend:latest
```

---

## Deploying with Helm

### Using the Deploy Script

```powershell
# Deploy with default settings
.\scripts\deploy.ps1

# Dry run (see what would be deployed)
.\scripts\deploy.ps1 -DryRun

# Deploy to custom namespace
.\scripts\deploy.ps1 -Namespace my-namespace

# Skip frontend (deploy backend only)
.\scripts\deploy.ps1 -SkipFrontend
```

### Manual Helm Deployment

```powershell
# Create namespace
kubectl create namespace todo-chatbot

# Deploy backend
helm upgrade --install todo-backend ./helm-charts/todo-backend `
    -n todo-chatbot `
    --set image.repository=todo-backend `
    --set image.tag=latest `
    --set image.pullPolicy=Never `
    --set secrets.databaseUrl="YOUR_DATABASE_URL" `
    --set secrets.jwtSecretKey="YOUR_JWT_SECRET" `
    --set secrets.groqApiKey="YOUR_GROQ_KEY"

# Deploy frontend
helm upgrade --install todo-frontend ./helm-charts/todo-frontend `
    -n todo-chatbot `
    --set image.repository=todo-frontend `
    --set image.tag=latest `
    --set image.pullPolicy=Never `
    --set config.apiUrl="http://todo-backend-svc:8000"
```

### Using Values File

Create a `values-local.yaml`:

```yaml
# values-local.yaml
secrets:
  databaseUrl: "postgresql://user:pass@host/db"
  jwtSecretKey: "your-secret-key"
  groqApiKey: "gsk_your_key"
```

Deploy with:

```powershell
helm upgrade --install todo-backend ./helm-charts/todo-backend `
    -n todo-chatbot `
    -f values-local.yaml
```

---

## Accessing the Application

### Method 1: NodePort (Default)

```powershell
# Get Minikube IP
$MINIKUBE_IP = minikube ip

# Access frontend
Start-Process "http://${MINIKUBE_IP}:30080"
```

### Method 2: Minikube Service

```powershell
# Opens browser automatically
minikube service todo-frontend-svc -n todo-chatbot
```

### Method 3: Port Forward

```powershell
# Forward frontend
kubectl port-forward svc/todo-frontend-svc 3000:80 -n todo-chatbot

# Forward backend (for API testing)
kubectl port-forward svc/todo-backend-svc 8000:8000 -n todo-chatbot
```

### Method 4: Minikube Tunnel

```powershell
# Run in separate terminal (requires admin)
minikube tunnel

# Access via localhost
Start-Process "http://localhost:30080"
```

---

## Configuration

### Backend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.corsOrigins` | CORS allowed origins | `http://todo-frontend-svc:3000,...` |
| `config.debug` | Debug mode | `false` |
| `config.aiProvider` | AI provider (groq/openai/anthropic) | `groq` |
| `secrets.databaseUrl` | PostgreSQL connection URL | Required |
| `secrets.jwtSecretKey` | JWT signing key | Required |
| `secrets.groqApiKey` | Groq API key | Required if using Groq |

### Frontend Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.apiUrl` | Backend API URL | `http://todo-backend-svc:8000` |
| `service.nodePort` | External port | `30080` |

### Resource Limits

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

---

## Upgrading

### Update Images

```powershell
# Rebuild images
.\scripts\build-images.ps1

# Upgrade deployment
.\scripts\deploy.ps1
```

### Rolling Update

```powershell
# Helm automatically performs rolling updates
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot

# Watch rollout
kubectl rollout status deployment/todo-backend -n todo-chatbot
```

### Rollback

```powershell
# View history
helm history todo-backend -n todo-chatbot

# Rollback to previous
helm rollback todo-backend 1 -n todo-chatbot
```

---

## Uninstalling

### Using Script

```powershell
# Uninstall releases, keep namespace
.\scripts\undeploy.ps1

# Uninstall everything including namespace
.\scripts\undeploy.ps1 -DeleteNamespace

# Force (no confirmation)
.\scripts\undeploy.ps1 -DeleteNamespace -Force
```

### Manual Uninstall

```powershell
# Uninstall Helm releases
helm uninstall todo-frontend -n todo-chatbot
helm uninstall todo-backend -n todo-chatbot

# Delete namespace
kubectl delete namespace todo-chatbot

# Stop Minikube
minikube stop

# Delete Minikube cluster (optional)
minikube delete
```

---

## Useful Commands

### Monitoring

```powershell
# View all resources
kubectl get all -n todo-chatbot

# Watch pods
kubectl get pods -n todo-chatbot -w

# View logs
kubectl logs -f deployment/todo-backend -n todo-chatbot
kubectl logs -f deployment/todo-frontend -n todo-chatbot

# Describe pod (troubleshooting)
kubectl describe pod <pod-name> -n todo-chatbot
```

### Debugging

```powershell
# Shell into backend container
kubectl exec -it deployment/todo-backend -n todo-chatbot -- /bin/bash

# Test backend health
kubectl exec deployment/todo-backend -n todo-chatbot -- curl -s http://localhost:8000/health

# View events
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp'
```

### Helm

```powershell
# List releases
helm list -n todo-chatbot

# Show values
helm get values todo-backend -n todo-chatbot

# Template (dry run)
helm template todo-backend ./helm-charts/todo-backend
```

---

## Next Steps

- Read [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
- Read [AI-TOOLS-GUIDE.md](./AI-TOOLS-GUIDE.md) for AI-assisted operations
- Check [ARCHITECTURE.md](./ARCHITECTURE.md) for system design details
