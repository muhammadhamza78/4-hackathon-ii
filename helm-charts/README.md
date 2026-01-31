# Todo Chatbot Helm Charts

This directory contains Helm charts for deploying the Todo Chatbot application on Kubernetes.

## Charts

| Chart | Description | Version |
|-------|-------------|---------|
| `todo-backend` | FastAPI backend API service | 1.0.0 |
| `todo-frontend` | Next.js frontend application | 1.0.0 |

## Quick Start

```bash
# Create namespace
kubectl create namespace todo-chatbot

# Deploy backend
helm upgrade --install todo-backend ./todo-backend \
    -n todo-chatbot \
    --set secrets.databaseUrl="YOUR_DATABASE_URL" \
    --set secrets.jwtSecretKey="YOUR_JWT_SECRET" \
    --set secrets.groqApiKey="YOUR_GROQ_KEY" \
    --set image.pullPolicy=Never

# Deploy frontend
helm upgrade --install todo-frontend ./todo-frontend \
    -n todo-chatbot \
    --set config.apiUrl="http://todo-backend-svc:8000" \
    --set image.pullPolicy=Never
```

## Backend Chart

### Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `todo-backend` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8000` |
| `config.corsOrigins` | CORS allowed origins | `http://todo-frontend-svc:3000,...` |
| `config.debug` | Debug mode | `false` |
| `config.aiProvider` | AI provider | `groq` |
| `secrets.databaseUrl` | Database URL | `""` |
| `secrets.jwtSecretKey` | JWT secret | `""` |
| `secrets.groqApiKey` | Groq API key | `""` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

### Example values file

```yaml
# backend-values.yaml
replicaCount: 2

image:
  repository: todo-backend
  tag: v1.0.0
  pullPolicy: Never

config:
  corsOrigins: "http://localhost:3000,http://localhost:30080"
  debug: "false"
  aiProvider: "groq"

secrets:
  databaseUrl: "postgresql://user:pass@host/db"
  jwtSecretKey: "your-secret-key"
  groqApiKey: "gsk_your_key"

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi
```

## Frontend Chart

### Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `todo-frontend` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `NodePort` |
| `service.port` | Service port | `80` |
| `service.nodePort` | NodePort | `30080` |
| `config.apiUrl` | Backend API URL | `http://todo-backend-svc:8000` |
| `ingress.enabled` | Enable ingress | `false` |

### Example values file

```yaml
# frontend-values.yaml
replicaCount: 2

image:
  repository: todo-frontend
  tag: v1.0.0
  pullPolicy: Never

service:
  type: NodePort
  port: 80
  nodePort: 30080

config:
  apiUrl: "http://todo-backend-svc:8000"

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: todo.local
      paths:
        - path: /
          pathType: Prefix
```

## Commands

```bash
# Lint charts
helm lint ./todo-backend
helm lint ./todo-frontend

# Template (dry run)
helm template todo-backend ./todo-backend
helm template todo-frontend ./todo-frontend

# Install
helm install todo-backend ./todo-backend -n todo-chatbot
helm install todo-frontend ./todo-frontend -n todo-chatbot

# Upgrade
helm upgrade todo-backend ./todo-backend -n todo-chatbot
helm upgrade todo-frontend ./todo-frontend -n todo-chatbot

# Uninstall
helm uninstall todo-backend -n todo-chatbot
helm uninstall todo-frontend -n todo-chatbot

# List releases
helm list -n todo-chatbot

# View values
helm get values todo-backend -n todo-chatbot

# Rollback
helm rollback todo-backend 1 -n todo-chatbot
```

## Dependencies

These charts have no external dependencies. They are standalone charts that deploy the application containers.

## Notes

- For local Minikube deployment, set `image.pullPolicy=Never` to use locally built images
- Secrets should be provided via `--set` flags or a values file (not committed to version control)
- The backend chart creates its own Secrets resource; set `secrets.create=false` to use external secrets
