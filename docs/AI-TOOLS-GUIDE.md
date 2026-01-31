# Phase IV - AI Tools Guide

This guide covers the usage of AI-assisted tools for Docker and Kubernetes operations in the Phase IV deployment.

## Table of Contents

1. [Overview](#overview)
2. [Docker AI (Gordon)](#docker-ai-gordon)
3. [kubectl-ai](#kubectl-ai)
4. [kagent](#kagent)
5. [Best Practices](#best-practices)
6. [Fallback Commands](#fallback-commands)

---

## Overview

AI-assisted tools can simplify DevOps operations by allowing natural language commands. This deployment supports three AI tools:

| Tool | Purpose | Fallback |
|------|---------|----------|
| Docker AI (Gordon) | AI-assisted Docker operations | Standard Docker CLI |
| kubectl-ai | Natural language Kubernetes commands | Standard kubectl |
| kagent | Kubernetes agent automation | Manual kubectl/Helm |

### Installation Status Check

```powershell
# Check if Docker AI is available
docker ai --version 2>$null || Write-Host "Docker AI not installed"

# Check if kubectl-ai is available
kubectl-ai --version 2>$null || Write-Host "kubectl-ai not installed"

# Check if kagent is available
kagent --version 2>$null || Write-Host "kagent not installed"
```

---

## Docker AI (Gordon)

Docker AI (Gordon) is an AI assistant integrated into Docker Desktop that helps with container operations using natural language.

### Installation

Docker AI comes bundled with Docker Desktop 4.30+. Enable it in Docker Desktop settings under "Features in development" → "Docker AI".

### Common Use Cases

#### Building Images

```bash
# Natural language image building
docker ai "build a production FastAPI image from the backend directory"

# Optimize Dockerfile
docker ai "optimize this Dockerfile for smaller image size"

# Multi-stage build help
docker ai "create a multi-stage Dockerfile for a Next.js app with standalone output"
```

#### Troubleshooting

```bash
# Debug container issues
docker ai "why is my container failing to start"

# Network debugging
docker ai "debug networking issue between my frontend and backend containers"

# Resource issues
docker ai "my container is using too much memory, how can I optimize it"
```

#### Image Management

```bash
# List and clean images
docker ai "show me all unused images and how to clean them"

# Analyze image size
docker ai "analyze the size of my todo-backend:latest image"

# Security scanning
docker ai "scan todo-backend:latest for vulnerabilities"
```

### Example Workflow

```bash
# 1. Get help building the backend
docker ai "build a production-ready image for a FastAPI app in ./backend"

# 2. Check the build
docker ai "verify todo-backend:latest is healthy and show its layers"

# 3. Troubleshoot if needed
docker ai "the backend container exits immediately, check the logs and suggest fixes"
```

### Fallback Commands

If Docker AI is unavailable:

```powershell
# Build backend
docker build -f docker/backend/Dockerfile -t todo-backend:latest ./backend

# Build frontend
docker build -f docker/frontend/Dockerfile -t todo-frontend:latest ./frontend

# View logs
docker logs <container-id>

# Inspect image
docker inspect todo-backend:latest

# Clean unused images
docker image prune -a
```

---

## kubectl-ai

kubectl-ai translates natural language into kubectl commands, making Kubernetes operations more accessible.

### Installation

```bash
# Using Homebrew (Mac/Linux)
brew install kubectl-ai

# Using Go
go install github.com/sozercan/kubectl-ai@latest

# Using Krew (kubectl plugin manager)
kubectl krew install ai
```

### Configuration

```bash
# Set OpenAI API key (required)
export OPENAI_API_KEY="your-api-key"

# Or use local LLM
export KUBECTL_AI_MODEL="local"
```

### Common Use Cases

#### Resource Creation

```bash
# Create deployment
kubectl-ai "create a deployment for todo-backend with 2 replicas"

# Create service
kubectl-ai "expose todo-frontend as a NodePort service on port 30080"

# Create configmap
kubectl-ai "create a configmap with API_URL=http://backend:8000"
```

#### Querying Resources

```bash
# Get pod status
kubectl-ai "show me all pods that are not running in todo-chatbot namespace"

# Find resource usage
kubectl-ai "which pods are using the most memory"

# Check events
kubectl-ai "show recent warning events in todo-chatbot namespace"
```

#### Troubleshooting

```bash
# Debug pods
kubectl-ai "why are my backend pods not starting"

# View logs
kubectl-ai "show error logs from todo-backend pods"

# Describe issues
kubectl-ai "describe the failing pod and tell me what's wrong"
```

#### Scaling and Updates

```bash
# Scale deployment
kubectl-ai "scale todo-frontend to 3 replicas"

# Rolling restart
kubectl-ai "restart all pods in todo-backend deployment"

# Update image
kubectl-ai "update todo-backend to use image tag v2.0"
```

### Example Workflow

```bash
# 1. Check deployment status
kubectl-ai "show me the status of all deployments in todo-chatbot namespace"

# 2. Investigate issues
kubectl-ai "why is todo-backend pod in CrashLoopBackOff"

# 3. Fix the issue
kubectl-ai "show me how to update the DATABASE_URL secret"

# 4. Verify fix
kubectl-ai "restart todo-backend and watch it come up"
```

### Fallback Commands

If kubectl-ai is unavailable:

```powershell
# Get all resources
kubectl get all -n todo-chatbot

# Describe pod
kubectl describe pod <pod-name> -n todo-chatbot

# View logs
kubectl logs -f deployment/todo-backend -n todo-chatbot

# Scale deployment
kubectl scale deployment/todo-backend --replicas=2 -n todo-chatbot

# Restart deployment
kubectl rollout restart deployment/todo-backend -n todo-chatbot

# Update secret
kubectl create secret generic todo-backend-secrets \
    --from-literal=DATABASE_URL="new-url" \
    -n todo-chatbot --dry-run=client -o yaml | kubectl apply -f -
```

---

## kagent

kagent is a Kubernetes agent that automates complex operations and provides intelligent assistance.

### Installation

```bash
# Using pip
pip install kagent

# Using Go
go install github.com/kagent-dev/kagent@latest
```

### Common Use Cases

#### Deployment Operations

```bash
# Deploy application
kagent deploy --chart ./helm-charts/todo-backend --namespace todo-chatbot

# Check deployment status
kagent status --namespace todo-chatbot

# Rollback deployment
kagent rollback --deployment todo-backend --namespace todo-chatbot
```

#### Health Monitoring

```bash
# Health check all resources
kagent health --all --namespace todo-chatbot

# Diagnose specific pod
kagent diagnose --pod todo-backend-xxx --namespace todo-chatbot

# Watch for issues
kagent watch --namespace todo-chatbot
```

#### Automated Operations

```bash
# Auto-fix common issues
kagent fix --deployment todo-backend --namespace todo-chatbot

# Optimize resources
kagent optimize --namespace todo-chatbot

# Generate reports
kagent report --namespace todo-chatbot --output report.html
```

### Example Workflow

```bash
# 1. Deploy with kagent
kagent deploy --chart ./helm-charts/todo-backend -n todo-chatbot --values values-local.yaml

# 2. Monitor health
kagent health --watch -n todo-chatbot

# 3. Diagnose issues
kagent diagnose -n todo-chatbot

# 4. Auto-remediate
kagent fix -n todo-chatbot --auto-approve
```

### Fallback Commands

If kagent is unavailable:

```powershell
# Deploy with Helm
helm upgrade --install todo-backend ./helm-charts/todo-backend -n todo-chatbot

# Check status
kubectl get all -n todo-chatbot
kubectl describe deployment/todo-backend -n todo-chatbot

# Rollback
helm rollback todo-backend 1 -n todo-chatbot

# Health check
kubectl exec deployment/todo-backend -n todo-chatbot -- curl -s http://localhost:8000/health
```

---

## Best Practices

### 1. Verify Before Applying

Always review AI-generated commands before execution:

```bash
# kubectl-ai shows the command before running
kubectl-ai "delete all pods in production" --dry-run

# Add confirmation
kubectl-ai "scale to 0 replicas" --confirm
```

### 2. Use Specific Context

Provide clear context for better results:

```bash
# Good: Specific and contextual
kubectl-ai "in todo-chatbot namespace, show me backend pods that have restarted more than 3 times"

# Less effective: Vague
kubectl-ai "show problem pods"
```

### 3. Combine with Traditional Commands

Use AI tools for complex queries, traditional commands for simple operations:

```bash
# AI for complex queries
kubectl-ai "find pods consuming more than 80% of their memory limit"

# Traditional for simple operations
kubectl get pods -n todo-chatbot
```

### 4. Learn from AI Suggestions

Use AI tools to learn kubectl commands:

```bash
# Ask for explanation
kubectl-ai "explain how to create a network policy that only allows frontend to talk to backend"
```

### 5. Fallback Strategy

Always have fallback commands ready:

```powershell
# Check if AI tool available, otherwise use fallback
if (Get-Command kubectl-ai -ErrorAction SilentlyContinue) {
    kubectl-ai "show pod status in todo-chatbot"
} else {
    kubectl get pods -n todo-chatbot -o wide
}
```

---

## Fallback Commands Reference

### Complete Fallback Script

If no AI tools are available, use this comprehensive script:

```powershell
# ==============================================================================
# Fallback Operations Script
# ==============================================================================

param(
    [string]$Namespace = "todo-chatbot"
)

function Show-Status {
    Write-Host "`n=== Cluster Status ===" -ForegroundColor Cyan
    kubectl get all -n $Namespace
}

function Show-PodLogs {
    param([string]$App)
    Write-Host "`n=== Logs for $App ===" -ForegroundColor Cyan
    kubectl logs -l app.kubernetes.io/name=$App -n $Namespace --tail=50
}

function Test-Health {
    Write-Host "`n=== Health Checks ===" -ForegroundColor Cyan

    $backendPod = kubectl get pods -l app.kubernetes.io/name=todo-backend -n $Namespace -o jsonpath='{.items[0].metadata.name}'
    if ($backendPod) {
        $health = kubectl exec $backendPod -n $Namespace -- curl -s http://localhost:8000/health
        Write-Host "Backend Health: $health"
    }
}

function Restart-Deployment {
    param([string]$Deployment)
    Write-Host "`n=== Restarting $Deployment ===" -ForegroundColor Cyan
    kubectl rollout restart deployment/$Deployment -n $Namespace
    kubectl rollout status deployment/$Deployment -n $Namespace
}

function Scale-Deployment {
    param([string]$Deployment, [int]$Replicas)
    Write-Host "`n=== Scaling $Deployment to $Replicas ===" -ForegroundColor Cyan
    kubectl scale deployment/$Deployment --replicas=$Replicas -n $Namespace
}

function Show-Events {
    Write-Host "`n=== Recent Events ===" -ForegroundColor Cyan
    kubectl get events -n $Namespace --sort-by='.lastTimestamp' | Select-Object -Last 20
}

function Diagnose-Pod {
    param([string]$PodName)
    Write-Host "`n=== Diagnosing $PodName ===" -ForegroundColor Cyan
    kubectl describe pod $PodName -n $Namespace
    Write-Host "`n=== Pod Logs ===" -ForegroundColor Cyan
    kubectl logs $PodName -n $Namespace --tail=100
}

# Main menu
Write-Host "Available commands:" -ForegroundColor Yellow
Write-Host "  Show-Status"
Write-Host "  Show-PodLogs -App todo-backend"
Write-Host "  Test-Health"
Write-Host "  Restart-Deployment -Deployment todo-backend"
Write-Host "  Scale-Deployment -Deployment todo-backend -Replicas 2"
Write-Host "  Show-Events"
Write-Host "  Diagnose-Pod -PodName <pod-name>"
```

---

## Additional Resources

- [Docker AI Documentation](https://docs.docker.com/ai/)
- [kubectl-ai GitHub](https://github.com/sozercan/kubectl-ai)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)

---

## Summary

| Task | AI Tool | Fallback |
|------|---------|----------|
| Build Docker image | `docker ai "build..."` | `docker build -f Dockerfile -t tag .` |
| Debug container | `docker ai "why is..."` | `docker logs <id>` |
| Get pod status | `kubectl-ai "show pods..."` | `kubectl get pods -n ns` |
| View logs | `kubectl-ai "show logs..."` | `kubectl logs deployment/name` |
| Scale deployment | `kubectl-ai "scale to..."` | `kubectl scale deployment --replicas=n` |
| Deploy with Helm | `kagent deploy --chart...` | `helm upgrade --install...` |
| Health check | `kagent health --all` | `kubectl exec ... -- curl /health` |
