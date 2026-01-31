# Phase IV - Troubleshooting Guide

This guide covers common issues and solutions for the Todo Chatbot Kubernetes deployment.

## Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Minikube Issues](#minikube-issues)
3. [Docker Build Issues](#docker-build-issues)
4. [Pod Issues](#pod-issues)
5. [Networking Issues](#networking-issues)
6. [Helm Issues](#helm-issues)
7. [Application Issues](#application-issues)
8. [Performance Issues](#performance-issues)

---

## Quick Diagnostics

Run these commands to quickly diagnose issues:

```powershell
# Check overall status
minikube status
kubectl get all -n todo-chatbot

# Check pod status
kubectl get pods -n todo-chatbot -o wide

# Check recent events
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp' | Select-Object -Last 20

# Check logs
kubectl logs -l app.kubernetes.io/name=todo-backend -n todo-chatbot --tail=50
kubectl logs -l app.kubernetes.io/name=todo-frontend -n todo-chatbot --tail=50

# Run validation script
.\scripts\validate.ps1 -Verbose
```

---

## Minikube Issues

### Minikube Won't Start

**Symptoms:**
- `minikube start` hangs or fails
- Error: "Unable to start VM"

**Solutions:**

```powershell
# 1. Check Docker is running
docker info

# 2. Delete and recreate cluster
minikube delete
minikube start --driver=docker --memory=4096 --cpus=4

# 3. Try different driver
minikube start --driver=hyperv  # Windows with Hyper-V
minikube start --driver=virtualbox  # If VirtualBox installed

# 4. Clean up Docker resources
docker system prune -a

# 5. Increase resources
minikube start --memory=8192 --cpus=4
```

### Minikube Out of Memory

**Symptoms:**
- Pods stuck in `Pending` or `OOMKilled`
- Node shows memory pressure

**Solutions:**

```powershell
# Check node resources
kubectl describe node minikube | Select-String -Pattern "memory|cpu" -Context 2

# Restart with more memory
minikube stop
minikube start --memory=8192

# Or reduce pod resource requests in values.yaml
```

### Cannot Connect to Minikube

**Symptoms:**
- `kubectl` commands timeout
- "Unable to connect to the server"

**Solutions:**

```powershell
# 1. Check Minikube status
minikube status

# 2. Set kubectl context
kubectl config use-context minikube

# 3. Restart Minikube
minikube stop
minikube start

# 4. Update kubeconfig
minikube update-context
```

---

## Docker Build Issues

### Build Fails - "COPY failed"

**Symptoms:**
- `COPY requirements.txt .` fails
- File not found errors

**Solutions:**

```powershell
# 1. Ensure you're in correct directory
cd C:\Users\DELL\Desktop\new\phase-4

# 2. Build with correct context
docker build -f docker/backend/Dockerfile -t todo-backend:latest ./backend

# 3. Check .dockerignore isn't excluding needed files
Get-Content docker/backend/.dockerignore
```

### Build Fails - Out of Space

**Symptoms:**
- "no space left on device"

**Solutions:**

```powershell
# 1. Clean Docker cache
docker system prune -a

# 2. Clean Minikube Docker
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker system prune -a

# 3. Increase Docker disk space in Docker Desktop settings
```

### Image Not Found in Minikube

**Symptoms:**
- `ImagePullBackOff` or `ErrImageNeverPull`
- "image not found"

**Solutions:**

```powershell
# 1. Ensure using Minikube's Docker daemon
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# 2. Rebuild images
docker build -f docker/backend/Dockerfile -t todo-backend:latest ./backend

# 3. Verify image exists
docker images | Select-String "todo"

# 4. Or load from local Docker
minikube image load todo-backend:latest
minikube image load todo-frontend:latest

# 5. Check image in Minikube
minikube image ls | Select-String "todo"
```

---

## Pod Issues

### Pod Stuck in Pending

**Symptoms:**
- Pod stays in `Pending` state
- `kubectl get pods` shows Pending

**Diagnosis:**

```powershell
kubectl describe pod <pod-name> -n todo-chatbot
```

**Common Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| Insufficient CPU/Memory | Reduce resource requests or increase Minikube resources |
| Image pull error | Check image name, rebuild, or load image |
| Node selector mismatch | Remove nodeSelector from values.yaml |

### Pod CrashLoopBackOff

**Symptoms:**
- Pod repeatedly restarts
- Status shows `CrashLoopBackOff`

**Diagnosis:**

```powershell
# Check logs
kubectl logs <pod-name> -n todo-chatbot --previous

# Check events
kubectl describe pod <pod-name> -n todo-chatbot
```

**Common Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| Missing environment variables | Check secrets and configmaps are created |
| Database connection failed | Verify DATABASE_URL is correct |
| Invalid configuration | Check application logs for specific errors |
| Health check failing | Increase initialDelaySeconds in probes |

```powershell
# Fix: Increase startup time
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot `
    --set livenessProbe.initialDelaySeconds=30 `
    --set readinessProbe.initialDelaySeconds=15
```

### Pod ImagePullBackOff

**Symptoms:**
- Pod shows `ImagePullBackOff` or `ErrImagePull`

**Solutions:**

```powershell
# 1. Check image name in deployment
kubectl get deployment todo-backend -n todo-chatbot -o yaml | Select-String "image:"

# 2. Ensure imagePullPolicy is Never for local images
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot `
    --set image.pullPolicy=Never

# 3. Verify image exists in Minikube
minikube image ls | Select-String "todo-backend"
```

### OOMKilled

**Symptoms:**
- Pod terminated with `OOMKilled`
- Container exceeds memory limit

**Solutions:**

```powershell
# 1. Increase memory limit
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot `
    --set resources.limits.memory=1Gi

# 2. Check actual memory usage
kubectl top pods -n todo-chatbot
```

---

## Networking Issues

### Cannot Access Frontend

**Symptoms:**
- Browser cannot reach http://<minikube-ip>:30080
- Connection refused

**Solutions:**

```powershell
# 1. Check service exists and has endpoints
kubectl get svc -n todo-chatbot
kubectl get endpoints -n todo-chatbot

# 2. Get correct URL
minikube service todo-frontend-svc -n todo-chatbot --url

# 3. Use minikube service (opens browser)
minikube service todo-frontend-svc -n todo-chatbot

# 4. Use port-forward as alternative
kubectl port-forward svc/todo-frontend-svc 3000:80 -n todo-chatbot
# Then access http://localhost:3000

# 5. Check Windows firewall
# May need to allow minikube through firewall
```

### Frontend Cannot Reach Backend

**Symptoms:**
- API calls fail from frontend
- CORS errors in browser console
- Network errors

**Diagnosis:**

```powershell
# 1. Check backend service
kubectl get svc todo-backend-svc -n todo-chatbot

# 2. Test from frontend pod
kubectl exec -it deployment/todo-frontend -n todo-chatbot -- wget -qO- http://todo-backend-svc:8000/health

# 3. Check CORS configuration
kubectl get configmap todo-backend-config -n todo-chatbot -o yaml
```

**Solutions:**

```powershell
# 1. Ensure backend service name is correct
kubectl get svc -n todo-chatbot

# 2. Update CORS origins
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot `
    --set config.corsOrigins="http://todo-frontend-svc:3000,http://localhost:30080"

# 3. Verify frontend config points to correct backend
kubectl get configmap todo-frontend-config -n todo-chatbot -o yaml
```

### DNS Resolution Failed

**Symptoms:**
- "could not resolve host"
- Service name not resolving

**Solutions:**

```powershell
# 1. Check CoreDNS is running
kubectl get pods -n kube-system | Select-String "coredns"

# 2. Test DNS from pod
kubectl exec -it deployment/todo-backend -n todo-chatbot -- nslookup todo-frontend-svc

# 3. Restart CoreDNS
kubectl rollout restart deployment/coredns -n kube-system
```

---

## Helm Issues

### Helm Install Fails

**Symptoms:**
- `helm install` or `helm upgrade` fails
- Template rendering errors

**Solutions:**

```powershell
# 1. Lint chart first
helm lint ./helm-charts/todo-backend

# 2. Template to see rendered output
helm template todo-backend ./helm-charts/todo-backend

# 3. Debug with --debug flag
helm upgrade --install todo-backend ./helm-charts/todo-backend -n todo-chatbot --debug

# 4. Check values file syntax
# Ensure YAML is valid
```

### Release Already Exists

**Symptoms:**
- "cannot re-use a name that is still in use"

**Solutions:**

```powershell
# 1. Use upgrade --install instead
helm upgrade --install todo-backend ./helm-charts/todo-backend -n todo-chatbot

# 2. Or uninstall first
helm uninstall todo-backend -n todo-chatbot
helm install todo-backend ./helm-charts/todo-backend -n todo-chatbot
```

### Secrets Not Applied

**Symptoms:**
- Environment variables empty in pod
- Application fails to start due to missing config

**Solutions:**

```powershell
# 1. Check secret exists
kubectl get secrets -n todo-chatbot

# 2. View secret (base64 encoded)
kubectl get secret todo-backend-secrets -n todo-chatbot -o yaml

# 3. Verify Helm values
helm get values todo-backend -n todo-chatbot

# 4. Redeploy with secrets
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot `
    --set secrets.databaseUrl="YOUR_URL" `
    --set secrets.jwtSecretKey="YOUR_KEY"
```

---

## Application Issues

### Backend Health Check Fails

**Symptoms:**
- `/health` endpoint returns error
- Readiness probe failing

**Diagnosis:**

```powershell
# Check logs
kubectl logs deployment/todo-backend -n todo-chatbot

# Test health endpoint
kubectl exec deployment/todo-backend -n todo-chatbot -- curl -v http://localhost:8000/health
```

**Solutions:**

```powershell
# 1. Check database connection
kubectl logs deployment/todo-backend -n todo-chatbot | Select-String -Pattern "database|connection"

# 2. Verify DATABASE_URL
kubectl exec deployment/todo-backend -n todo-chatbot -- printenv DATABASE_URL

# 3. Increase probe timeouts
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot `
    --set livenessProbe.timeoutSeconds=10 `
    --set livenessProbe.initialDelaySeconds=30
```

### Database Connection Failed

**Symptoms:**
- "could not connect to server"
- "connection refused"

**Solutions:**

```powershell
# 1. Verify DATABASE_URL format
# Should be: postgresql://user:pass@host:port/db?sslmode=require

# 2. Test connectivity from pod
kubectl exec -it deployment/todo-backend -n todo-chatbot -- curl -v telnet://your-db-host:5432

# 3. Check if external network accessible
kubectl exec -it deployment/todo-backend -n todo-chatbot -- curl -v https://google.com

# 4. For Neon, ensure SSL mode is correct
# sslmode=require&channel_binding=require
```

### AI/Chat Not Working

**Symptoms:**
- Chat returns errors
- AI responses failing

**Solutions:**

```powershell
# 1. Check AI provider configuration
kubectl get configmap todo-backend-config -n todo-chatbot -o yaml | Select-String "AI_PROVIDER"

# 2. Verify API key
kubectl exec deployment/todo-backend -n todo-chatbot -- printenv GROQ_API_KEY

# 3. Check logs for API errors
kubectl logs deployment/todo-backend -n todo-chatbot | Select-String -Pattern "groq|openai|api"

# 4. Test API connectivity
kubectl exec -it deployment/todo-backend -n todo-chatbot -- curl -v https://api.groq.com
```

---

## Performance Issues

### Slow Response Times

**Solutions:**

```powershell
# 1. Check resource usage
kubectl top pods -n todo-chatbot

# 2. Increase resources
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot `
    --set resources.requests.cpu=200m `
    --set resources.requests.memory=256Mi `
    --set resources.limits.cpu=1000m `
    --set resources.limits.memory=1Gi

# 3. Scale up replicas
kubectl scale deployment/todo-backend --replicas=2 -n todo-chatbot
```

### High Memory Usage

**Solutions:**

```powershell
# 1. Monitor memory
kubectl top pods -n todo-chatbot

# 2. Check for memory leaks in logs
kubectl logs deployment/todo-backend -n todo-chatbot | Select-String "memory"

# 3. Restart pods
kubectl rollout restart deployment/todo-backend -n todo-chatbot
```

---

## Getting Help

If issues persist:

1. **Collect diagnostics:**
   ```powershell
   kubectl get all -n todo-chatbot > diagnostics.txt
   kubectl describe pods -n todo-chatbot >> diagnostics.txt
   kubectl logs -l app.kubernetes.io/part-of=todo-chatbot -n todo-chatbot >> diagnostics.txt
   ```

2. **Check Minikube logs:**
   ```powershell
   minikube logs > minikube-logs.txt
   ```

3. **Review the deployment guide:** [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)

4. **Use AI tools for assistance:** [AI-TOOLS-GUIDE.md](./AI-TOOLS-GUIDE.md)
