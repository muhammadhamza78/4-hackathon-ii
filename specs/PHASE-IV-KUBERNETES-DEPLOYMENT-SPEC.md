# Phase IV — Local Kubernetes Deployment Specification

**Document Version:** 1.0
**Date:** 2026-01-18
**Status:** Draft
**Author:** Claude Code (AI-Generated)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Objectives](#2-objectives)
3. [Functional Requirements](#3-functional-requirements)
4. [Non-Functional Requirements](#4-non-functional-requirements)
5. [Architecture Overview](#5-architecture-overview)
6. [Deployment Model](#6-deployment-model)
7. [Tooling Matrix](#7-tooling-matrix)
8. [Container Specifications](#8-container-specifications)
9. [Helm Chart Specifications](#9-helm-chart-specifications)
10. [Configuration Management](#10-configuration-management)
11. [Networking Architecture](#11-networking-architecture)
12. [Assumptions](#12-assumptions)
13. [Constraints](#13-constraints)
14. [Out-of-Scope Items](#14-out-of-scope-items)
15. [Success Criteria](#15-success-criteria)
16. [Final Deliverables](#16-final-deliverables)
17. [Implementation Phases](#17-implementation-phases)
18. [Risk Assessment](#18-risk-assessment)

---

## 1. Executive Summary

This specification defines the requirements and architecture for deploying the Phase III Todo Chatbot application on a local Kubernetes cluster using Minikube. The deployment will leverage Docker for containerization and Helm charts for Kubernetes resource management, with AI-assisted tooling (Docker AI Gordon, kubectl-ai, kagent) to automate operations where available.

### 1.1 Application Overview

The Phase III Todo Chatbot consists of:
- **Frontend:** Next.js 16.1.1 application with React 19, TypeScript, and Tailwind CSS
- **Backend:** FastAPI 0.115.0+ with SQLModel ORM, JWT authentication, and AI chatbot integration
- **Database:** PostgreSQL (external Neon serverless instance)
- **AI Integration:** Groq/OpenAI/Anthropic for chatbot functionality

### 1.2 Deployment Target

- **Platform:** Local Minikube Kubernetes cluster
- **Container Runtime:** Docker Desktop
- **Package Manager:** Helm 3.x
- **AI Tooling:** kubectl-ai, kagent, Docker AI (Gordon)

---

## 2. Objectives

### 2.1 Primary Objectives

| ID | Objective | Priority |
|----|-----------|----------|
| O-01 | Containerize the FastAPI backend application using Docker | Critical |
| O-02 | Containerize the Next.js frontend application using Docker | Critical |
| O-03 | Create Helm charts for both frontend and backend services | Critical |
| O-04 | Deploy the complete application stack on Minikube | Critical |
| O-05 | Enable inter-service communication within the cluster | Critical |
| O-06 | Expose the frontend service for local browser access | Critical |

### 2.2 Secondary Objectives

| ID | Objective | Priority |
|----|-----------|----------|
| O-07 | Utilize AI-assisted tooling (Gordon, kubectl-ai, kagent) for operations | High |
| O-08 | Implement health checks and readiness probes | High |
| O-09 | Configure environment-based settings management | High |
| O-10 | Document all deployment procedures | Medium |
| O-11 | Create reproducible deployment scripts | Medium |

### 2.3 Research Objectives

| ID | Objective | Priority |
|----|-----------|----------|
| R-01 | Demonstrate spec-driven infrastructure development | Medium |
| R-02 | Establish blueprints for spec-to-infrastructure execution | Medium |
| R-03 | Explore AIOps workflows with kubectl-ai and kagent | Medium |

---

## 3. Functional Requirements

### 3.1 Containerization Requirements

#### FR-01: Backend Containerization
```
ID: FR-01
Title: FastAPI Backend Docker Container
Description: The backend application must be containerized with all dependencies
Acceptance Criteria:
  - Dockerfile builds successfully
  - Container starts and serves API on port 8000
  - All Python dependencies are installed
  - Environment variables are configurable at runtime
  - Health endpoint responds with 200 OK
```

#### FR-02: Frontend Containerization
```
ID: FR-02
Title: Next.js Frontend Docker Container
Description: The frontend application must be containerized for production deployment
Acceptance Criteria:
  - Multi-stage Dockerfile for optimized image size
  - Container serves application on port 3000
  - Production build is created during image build
  - Environment variables are injectable at runtime
  - Static assets are properly served
```

#### FR-03: Image Registry
```
ID: FR-03
Title: Local Image Registry Usage
Description: Docker images must be accessible to Minikube
Acceptance Criteria:
  - Images are built within Minikube's Docker daemon OR
  - Images are loaded into Minikube via 'minikube image load' OR
  - Images are pushed to a local registry accessible by Minikube
```

### 3.2 Kubernetes Deployment Requirements

#### FR-04: Backend Deployment
```
ID: FR-04
Title: Backend Kubernetes Deployment
Description: Deploy backend as a Kubernetes Deployment resource
Acceptance Criteria:
  - Deployment manages backend pod replicas
  - Pod template includes resource limits/requests
  - Liveness and readiness probes configured
  - Environment variables injected via ConfigMap/Secret
  - Service exposes backend within cluster
```

#### FR-05: Frontend Deployment
```
ID: FR-05
Title: Frontend Kubernetes Deployment
Description: Deploy frontend as a Kubernetes Deployment resource
Acceptance Criteria:
  - Deployment manages frontend pod replicas
  - Pod template includes resource limits/requests
  - Liveness and readiness probes configured
  - Environment variables point to backend service
  - Service exposes frontend (NodePort or Ingress)
```

#### FR-06: Service Discovery
```
ID: FR-06
Title: Internal Service Communication
Description: Frontend must communicate with backend via Kubernetes DNS
Acceptance Criteria:
  - Backend Service has ClusterIP type
  - Frontend resolves backend via service name
  - API calls from frontend reach backend successfully
  - CORS is configured for cluster networking
```

### 3.3 Helm Chart Requirements

#### FR-07: Backend Helm Chart
```
ID: FR-07
Title: Backend Helm Chart Package
Description: Helm chart for backend deployment with configurable values
Acceptance Criteria:
  - Chart.yaml with proper metadata
  - values.yaml with all configurable parameters
  - Deployment, Service, ConfigMap, Secret templates
  - Support for resource customization
  - Health check configuration
```

#### FR-08: Frontend Helm Chart
```
ID: FR-08
Title: Frontend Helm Chart Package
Description: Helm chart for frontend deployment with configurable values
Acceptance Criteria:
  - Chart.yaml with proper metadata
  - values.yaml with all configurable parameters
  - Deployment, Service templates
  - Ingress template (optional)
  - Backend URL configuration
```

### 3.4 External Access Requirements

#### FR-09: Frontend Accessibility
```
ID: FR-09
Title: Local Browser Access to Frontend
Description: Frontend must be accessible from host machine browser
Acceptance Criteria:
  - Service exposed via NodePort OR Minikube tunnel
  - Accessible URL documented
  - Port forwarding commands provided as alternative
```

---

## 4. Non-Functional Requirements

### 4.1 Performance Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-01 | Backend container startup time | < 30 seconds |
| NFR-02 | Frontend container startup time | < 60 seconds |
| NFR-03 | Backend image size | < 500 MB |
| NFR-04 | Frontend image size | < 1 GB |
| NFR-05 | Pod readiness after deployment | < 90 seconds |

### 4.2 Reliability Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-06 | Backend health check interval | 10 seconds |
| NFR-07 | Frontend health check interval | 15 seconds |
| NFR-08 | Pod restart policy | Always |
| NFR-09 | Minimum available replicas | 1 |

### 4.3 Resource Requirements

| ID | Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|----|-----------|-------------|-----------|----------------|--------------|
| NFR-10 | Backend | 100m | 500m | 128Mi | 512Mi |
| NFR-11 | Frontend | 100m | 500m | 128Mi | 512Mi |

### 4.4 Security Requirements

| ID | Requirement | Description |
|----|-------------|-------------|
| NFR-12 | Secret Management | Sensitive data stored in Kubernetes Secrets |
| NFR-13 | Non-root Container | Containers run as non-root user |
| NFR-14 | Read-only Filesystem | Where applicable, use read-only root filesystem |
| NFR-15 | Network Policies | Restrict inter-pod communication (optional) |

### 4.5 Maintainability Requirements

| ID | Requirement | Description |
|----|-------------|-------------|
| NFR-16 | Configuration Externalization | All config via ConfigMaps/Secrets |
| NFR-17 | Version Labeling | All resources labeled with app version |
| NFR-18 | Reproducible Builds | Dockerfiles produce consistent images |

---

## 5. Architecture Overview

### 5.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              HOST MACHINE                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         MINIKUBE CLUSTER                             │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │                    KUBERNETES NAMESPACE                      │    │   │
│  │  │                      (todo-chatbot)                          │    │   │
│  │  │                                                               │    │   │
│  │  │   ┌─────────────────┐         ┌─────────────────┐           │    │   │
│  │  │   │   FRONTEND      │         │    BACKEND      │           │    │   │
│  │  │   │   Deployment    │         │   Deployment    │           │    │   │
│  │  │   │                 │         │                 │           │    │   │
│  │  │   │ ┌─────────────┐ │         │ ┌─────────────┐ │           │    │   │
│  │  │   │ │  Next.js    │ │  HTTP   │ │  FastAPI    │ │           │    │   │
│  │  │   │ │  Container  │─┼────────►│ │  Container  │ │           │    │   │
│  │  │   │ │  :3000      │ │         │ │  :8000      │ │           │    │   │
│  │  │   │ └─────────────┘ │         │ └─────────────┘ │           │    │   │
│  │  │   └────────┬────────┘         └────────┬────────┘           │    │   │
│  │  │            │                           │                     │    │   │
│  │  │   ┌────────▼────────┐         ┌────────▼────────┐           │    │   │
│  │  │   │    Service      │         │    Service      │           │    │   │
│  │  │   │   (NodePort)    │         │  (ClusterIP)    │           │    │   │
│  │  │   │   :30080        │         │    :8000        │           │    │   │
│  │  │   └────────┬────────┘         └─────────────────┘           │    │   │
│  │  │            │                                                 │    │   │
│  │  │   ┌────────▼────────┐    ┌─────────────────────────────┐   │    │   │
│  │  │   │   ConfigMap     │    │         Secrets              │   │    │   │
│  │  │   │ (frontend-cfg)  │    │  (db-credentials, jwt-key,   │   │    │   │
│  │  │   └─────────────────┘    │   ai-api-keys)               │   │    │   │
│  │  │                          └─────────────────────────────┘   │    │   │
│  │  └───────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│                          minikube tunnel                                     │
│                                    │                                         │
│  ┌─────────────────────────────────▼─────────────────────────────────────┐  │
│  │                         BROWSER ACCESS                                 │  │
│  │                    http://localhost:30080                              │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS (External)
                                      ▼
                    ┌─────────────────────────────────┐
                    │      EXTERNAL SERVICES          │
                    │                                 │
                    │  ┌───────────────────────────┐  │
                    │  │   Neon PostgreSQL         │  │
                    │  │   (Database)              │  │
                    │  └───────────────────────────┘  │
                    │                                 │
                    │  ┌───────────────────────────┐  │
                    │  │   Groq/OpenAI/Anthropic   │  │
                    │  │   (AI API)                │  │
                    │  └───────────────────────────┘  │
                    └─────────────────────────────────┘
```

### 5.2 Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     KUBERNETES RESOURCES                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  NAMESPACE: todo-chatbot                                         │
│  ├── Deployment: todo-frontend                                   │
│  │   ├── ReplicaSet                                              │
│  │   └── Pod(s): todo-frontend-*                                 │
│  │       └── Container: frontend (nextjs:latest)                 │
│  │                                                               │
│  ├── Deployment: todo-backend                                    │
│  │   ├── ReplicaSet                                              │
│  │   └── Pod(s): todo-backend-*                                  │
│  │       └── Container: backend (fastapi:latest)                 │
│  │                                                               │
│  ├── Service: todo-frontend-svc (NodePort)                       │
│  │   └── Port: 80 → 3000, NodePort: 30080                        │
│  │                                                               │
│  ├── Service: todo-backend-svc (ClusterIP)                       │
│  │   └── Port: 8000 → 8000                                       │
│  │                                                               │
│  ├── ConfigMap: todo-frontend-config                             │
│  │   └── NEXT_PUBLIC_API_URL                                     │
│  │                                                               │
│  ├── ConfigMap: todo-backend-config                              │
│  │   └── CORS_ORIGINS, DEBUG, AI_PROVIDER                        │
│  │                                                               │
│  ├── Secret: todo-backend-secrets                                │
│  │   └── DATABASE_URL, JWT_SECRET_KEY, GROQ_API_KEY              │
│  │                                                               │
│  └── (Optional) Ingress: todo-ingress                            │
│      └── Rules for frontend and backend routing                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.3 Container Build Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DOCKER BUILD PIPELINE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  BACKEND (FastAPI)                                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Stage 1: Builder                                        │    │
│  │  ├── Base: python:3.11-slim                              │    │
│  │  ├── Install: requirements.txt                           │    │
│  │  └── Copy: Application source                            │    │
│  │                                                          │    │
│  │  Stage 2: Runtime                                        │    │
│  │  ├── Base: python:3.11-slim                              │    │
│  │  ├── Copy: Installed packages + source                   │    │
│  │  ├── User: non-root (appuser)                            │    │
│  │  ├── Expose: 8000                                        │    │
│  │  └── CMD: uvicorn app.main:app                           │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  FRONTEND (Next.js)                                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Stage 1: Dependencies                                   │    │
│  │  ├── Base: node:20-alpine                                │    │
│  │  ├── Install: package.json dependencies                  │    │
│  │  └── Copy: node_modules                                  │    │
│  │                                                          │    │
│  │  Stage 2: Builder                                        │    │
│  │  ├── Base: node:20-alpine                                │    │
│  │  ├── Copy: Source + node_modules                         │    │
│  │  └── Run: npm run build                                  │    │
│  │                                                          │    │
│  │  Stage 3: Runner                                         │    │
│  │  ├── Base: node:20-alpine                                │    │
│  │  ├── Copy: .next/standalone + static + public           │    │
│  │  ├── User: non-root (nextjs)                             │    │
│  │  ├── Expose: 3000                                        │    │
│  │  └── CMD: node server.js                                 │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Deployment Model

### 6.1 Deployment Strategy

| Aspect | Strategy | Rationale |
|--------|----------|-----------|
| Deployment Type | Rolling Update | Zero-downtime deployments |
| Rollback | Automatic | On failed health checks |
| Scaling | Manual (HPA optional) | Local development scope |
| State Management | Stateless | Database external to cluster |

### 6.2 Deployment Sequence

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT SEQUENCE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Phase 1: Prerequisites                                          │
│  ├── 1.1 Verify Minikube is running                              │
│  ├── 1.2 Configure Docker to use Minikube daemon                 │
│  └── 1.3 Create namespace (if not exists)                        │
│                                                                  │
│  Phase 2: Build Container Images                                 │
│  ├── 2.1 Build backend image (todo-backend:latest)               │
│  ├── 2.2 Build frontend image (todo-frontend:latest)             │
│  └── 2.3 Verify images in Minikube                               │
│                                                                  │
│  Phase 3: Deploy Configuration                                   │
│  ├── 3.1 Create/Update ConfigMaps                                │
│  └── 3.2 Create/Update Secrets                                   │
│                                                                  │
│  Phase 4: Deploy Backend                                         │
│  ├── 4.1 Install/Upgrade backend Helm chart                      │
│  ├── 4.2 Wait for backend pods ready                             │
│  └── 4.3 Verify backend health endpoint                          │
│                                                                  │
│  Phase 5: Deploy Frontend                                        │
│  ├── 5.1 Install/Upgrade frontend Helm chart                     │
│  ├── 5.2 Wait for frontend pods ready                            │
│  └── 5.3 Verify frontend accessibility                           │
│                                                                  │
│  Phase 6: Validation                                             │
│  ├── 6.1 Test frontend-backend communication                     │
│  ├── 6.2 Verify all endpoints functional                         │
│  └── 6.3 Document access URLs                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 6.3 Namespace Strategy

```yaml
Namespace: todo-chatbot
Purpose: Isolate all application resources
Labels:
  app.kubernetes.io/name: todo-chatbot
  app.kubernetes.io/part-of: phase-4-deployment
  environment: local
```

---

## 7. Tooling Matrix

### 7.1 Primary Tools

| Tool | Version | Purpose | Required |
|------|---------|---------|----------|
| Docker Desktop | Latest | Container runtime | Yes |
| Minikube | v1.32+ | Local Kubernetes cluster | Yes |
| kubectl | v1.28+ | Kubernetes CLI | Yes |
| Helm | v3.13+ | Kubernetes package manager | Yes |

### 7.2 AI-Assisted Tools

| Tool | Purpose | Fallback |
|------|---------|----------|
| Docker AI (Gordon) | AI-assisted Docker operations | Standard Docker CLI |
| kubectl-ai | Natural language Kubernetes commands | Standard kubectl |
| kagent | Kubernetes agent automation | Manual kubectl/Helm commands |

### 7.3 Development Tools

| Tool | Purpose | Required |
|------|---------|----------|
| Node.js | Frontend build | v20+ |
| Python | Backend runtime | 3.11+ |
| Git | Version control | Yes |

### 7.4 AI Tool Usage Patterns

#### Docker AI (Gordon) Usage
```bash
# Image building assistance
docker ai "build a production-ready FastAPI image from ./backend"
docker ai "create multi-stage Dockerfile for Next.js app"
docker ai "optimize this Dockerfile for smaller image size"

# Troubleshooting
docker ai "why is my container failing to start"
docker ai "debug networking issue between containers"
```

#### kubectl-ai Usage
```bash
# Resource creation
kubectl-ai "create deployment for backend with 2 replicas"
kubectl-ai "expose frontend service on NodePort 30080"
kubectl-ai "create configmap from environment variables"

# Debugging
kubectl-ai "show me why pods are not starting"
kubectl-ai "get logs from all backend pods"
kubectl-ai "describe the failing deployment"
```

#### kagent Usage
```bash
# Automated operations
kagent deploy --chart ./helm-charts/todo-backend
kagent status --namespace todo-chatbot
kagent rollback --deployment todo-frontend

# Health monitoring
kagent health --all
kagent diagnose --pod todo-backend-xxx
```

---

## 8. Container Specifications

### 8.1 Backend Container (FastAPI)

```dockerfile
# Specification for backend Dockerfile
Base Image: python:3.11-slim
Working Directory: /app
Exposed Port: 8000
Non-root User: appuser (UID 1001)

Environment Variables (Runtime):
  - DATABASE_URL (required)
  - JWT_SECRET_KEY (required)
  - CORS_ORIGINS (required)
  - AI_PROVIDER (default: groq)
  - GROQ_API_KEY (required if groq)
  - DEBUG (default: False)

Health Check:
  - Endpoint: /health
  - Interval: 30s
  - Timeout: 10s
  - Retries: 3

Entry Point:
  uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 8.2 Frontend Container (Next.js)

```dockerfile
# Specification for frontend Dockerfile
Base Image: node:20-alpine
Working Directory: /app
Exposed Port: 3000
Non-root User: nextjs (UID 1001)

Build Arguments:
  - NEXT_PUBLIC_API_URL (build-time API URL)

Environment Variables (Runtime):
  - NODE_ENV=production
  - HOSTNAME=0.0.0.0
  - PORT=3000

Health Check:
  - Endpoint: /api/health (or TCP check on 3000)
  - Interval: 30s
  - Timeout: 10s
  - Retries: 3

Build Output: Standalone mode (.next/standalone)

Entry Point:
  node server.js
```

### 8.3 Image Naming Convention

```
Repository: local/todo-chatbot
Tags:
  - todo-backend:latest
  - todo-backend:v1.0.0
  - todo-frontend:latest
  - todo-frontend:v1.0.0
```

---

## 9. Helm Chart Specifications

### 9.1 Backend Helm Chart Structure

```
helm-charts/todo-backend/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── hpa.yaml (optional)
│   └── NOTES.txt
└── .helmignore
```

#### Chart.yaml
```yaml
apiVersion: v2
name: todo-backend
description: FastAPI backend for Todo Chatbot application
type: application
version: 1.0.0
appVersion: "1.0.0"
keywords:
  - fastapi
  - backend
  - api
maintainers:
  - name: Claude Code
```

#### values.yaml (Key Parameters)
```yaml
replicaCount: 1
image:
  repository: todo-backend
  tag: latest
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 8000
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
config:
  corsOrigins: "http://todo-frontend-svc:3000"
  debug: "false"
  aiProvider: "groq"
secrets:
  databaseUrl: ""
  jwtSecretKey: ""
  groqApiKey: ""
probes:
  liveness:
    path: /health
    initialDelaySeconds: 15
    periodSeconds: 10
  readiness:
    path: /health
    initialDelaySeconds: 5
    periodSeconds: 5
```

### 9.2 Frontend Helm Chart Structure

```
helm-charts/todo-frontend/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── ingress.yaml (optional)
│   └── NOTES.txt
└── .helmignore
```

#### Chart.yaml
```yaml
apiVersion: v2
name: todo-frontend
description: Next.js frontend for Todo Chatbot application
type: application
version: 1.0.0
appVersion: "1.0.0"
keywords:
  - nextjs
  - frontend
  - react
maintainers:
  - name: Claude Code
```

#### values.yaml (Key Parameters)
```yaml
replicaCount: 1
image:
  repository: todo-frontend
  tag: latest
  pullPolicy: IfNotPresent
service:
  type: NodePort
  port: 80
  targetPort: 3000
  nodePort: 30080
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
config:
  apiUrl: "http://todo-backend-svc:8000"
probes:
  liveness:
    path: /
    initialDelaySeconds: 30
    periodSeconds: 15
  readiness:
    path: /
    initialDelaySeconds: 10
    periodSeconds: 5
ingress:
  enabled: false
  className: nginx
  hosts:
    - host: todo.local
      paths:
        - path: /
          pathType: Prefix
```

---

## 10. Configuration Management

### 10.1 ConfigMap Specifications

#### Backend ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: todo-backend-config
  namespace: todo-chatbot
data:
  CORS_ORIGINS: "http://todo-frontend-svc:3000,http://localhost:30080"
  DEBUG: "false"
  AI_PROVIDER: "groq"
```

#### Frontend ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: todo-frontend-config
  namespace: todo-chatbot
data:
  NEXT_PUBLIC_API_URL: "http://todo-backend-svc:8000"
```

### 10.2 Secret Specifications

#### Backend Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: todo-backend-secrets
  namespace: todo-chatbot
type: Opaque
data:
  DATABASE_URL: <base64-encoded>
  JWT_SECRET_KEY: <base64-encoded>
  GROQ_API_KEY: <base64-encoded>
```

### 10.3 Environment Variable Mapping

| Variable | Source | Component | Type |
|----------|--------|-----------|------|
| DATABASE_URL | Secret | Backend | Required |
| JWT_SECRET_KEY | Secret | Backend | Required |
| GROQ_API_KEY | Secret | Backend | Required |
| CORS_ORIGINS | ConfigMap | Backend | Required |
| DEBUG | ConfigMap | Backend | Optional |
| AI_PROVIDER | ConfigMap | Backend | Optional |
| NEXT_PUBLIC_API_URL | ConfigMap | Frontend | Required |

---

## 11. Networking Architecture

### 11.1 Service Topology

```
┌─────────────────────────────────────────────────────────────┐
│                    CLUSTER NETWORKING                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  External Access (Host Machine)                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Browser → http://localhost:30080                    │    │
│  │         → minikube service todo-frontend-svc         │    │
│  │         → minikube tunnel (alternative)              │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                   │
│                          ▼                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Frontend Service (NodePort)                         │    │
│  │  Name: todo-frontend-svc                             │    │
│  │  Port: 80 → 3000                                     │    │
│  │  NodePort: 30080                                     │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                   │
│                          │ Internal Cluster Network          │
│                          ▼                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Backend Service (ClusterIP)                         │    │
│  │  Name: todo-backend-svc                              │    │
│  │  Port: 8000 → 8000                                   │    │
│  │  DNS: todo-backend-svc.todo-chatbot.svc.cluster.local│    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                   │
│                          │ External HTTPS                    │
│                          ▼                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  External Services                                   │    │
│  │  - Neon PostgreSQL (DATABASE_URL)                    │    │
│  │  - Groq API (api.groq.com)                           │    │
│  │  - OpenAI API (api.openai.com)                       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 11.2 DNS Resolution

| Service | Internal DNS | Port |
|---------|--------------|------|
| Backend | todo-backend-svc.todo-chatbot.svc.cluster.local | 8000 |
| Backend (short) | todo-backend-svc | 8000 |
| Frontend | todo-frontend-svc.todo-chatbot.svc.cluster.local | 80 |

### 11.3 CORS Configuration

```python
# Backend CORS must include:
CORS_ORIGINS = [
    "http://todo-frontend-svc:3000",      # Internal cluster
    "http://localhost:30080",              # NodePort access
    "http://127.0.0.1:30080",              # Alternative localhost
    "http://<minikube-ip>:30080"           # Minikube IP access
]
```

---

## 12. Assumptions

### 12.1 Infrastructure Assumptions

| ID | Assumption |
|----|------------|
| A-01 | Docker Desktop is installed and running on the host machine |
| A-02 | Minikube is installed and can be started successfully |
| A-03 | Sufficient system resources (8GB RAM, 4 CPU cores recommended) |
| A-04 | Host machine has internet access for external API calls |
| A-05 | kubectl is installed and configured |
| A-06 | Helm v3 is installed |

### 12.2 Application Assumptions

| ID | Assumption |
|----|------------|
| A-07 | Phase III application code is complete and functional |
| A-08 | External Neon PostgreSQL database remains accessible |
| A-09 | Groq/AI API keys are valid and have sufficient quota |
| A-10 | No code modifications required for containerization |
| A-11 | Application can run with environment variable configuration |

### 12.3 Network Assumptions

| ID | Assumption |
|----|------------|
| A-12 | Ports 30080 is available on the host machine |
| A-13 | No firewall blocking container-to-internet traffic |
| A-14 | DNS resolution works within the Kubernetes cluster |

---

## 13. Constraints

### 13.1 Technical Constraints

| ID | Constraint | Impact |
|----|------------|--------|
| C-01 | Local deployment only (Minikube) | No cloud-specific features |
| C-02 | Single-node cluster | No multi-node testing |
| C-03 | No persistent volumes required | Database is external |
| C-04 | Windows host environment | Path handling considerations |
| C-05 | No manual coding allowed | All artifacts AI-generated |

### 13.2 Resource Constraints

| ID | Constraint | Value |
|----|------------|-------|
| C-06 | Max CPU per pod | 500m |
| C-07 | Max Memory per pod | 512Mi |
| C-08 | Max replicas (local) | 2 per service |
| C-09 | Minikube memory allocation | 4GB recommended |

### 13.3 Security Constraints

| ID | Constraint | Description |
|----|------------|-------------|
| C-10 | Secrets in plain files | For local dev; encrypt for production |
| C-11 | No TLS termination | HTTP only for local |
| C-12 | No network policies | Simplified for local dev |

---

## 14. Out-of-Scope Items

### 14.1 Explicitly Excluded

| ID | Item | Reason |
|----|------|--------|
| OOS-01 | Cloud deployment (AWS, GCP, Azure) | Local Minikube only |
| OOS-02 | CI/CD pipeline setup | Not required for local deployment |
| OOS-03 | Production-grade monitoring (Prometheus, Grafana) | Local development scope |
| OOS-04 | Service mesh (Istio, Linkerd) | Over-engineering for local |
| OOS-05 | Database deployment in Kubernetes | Using external Neon |
| OOS-06 | TLS/SSL certificate management | HTTP sufficient locally |
| OOS-07 | Multi-cluster deployment | Single Minikube cluster |
| OOS-08 | GitOps (ArgoCD, Flux) | Manual deployment acceptable |
| OOS-09 | Backup and disaster recovery | External database handles this |
| OOS-10 | Load testing and performance benchmarking | Functional deployment focus |

### 14.2 Future Considerations

| ID | Item | Notes |
|----|------|-------|
| FC-01 | Horizontal Pod Autoscaler | Templates can be added |
| FC-02 | Ingress with TLS | For production migration |
| FC-03 | Pod Disruption Budgets | For HA requirements |
| FC-04 | Resource quotas | For multi-tenant scenarios |

---

## 15. Success Criteria

### 15.1 Must-Have Criteria (MVP)

| ID | Criterion | Verification Method |
|----|-----------|---------------------|
| SC-01 | Backend Docker image builds successfully | `docker build` exits 0 |
| SC-02 | Frontend Docker image builds successfully | `docker build` exits 0 |
| SC-03 | Images load into Minikube | `minikube image ls` shows images |
| SC-04 | Backend Helm chart installs without errors | `helm install` exits 0 |
| SC-05 | Frontend Helm chart installs without errors | `helm install` exits 0 |
| SC-06 | Backend pods reach Running state | `kubectl get pods` shows Running |
| SC-07 | Frontend pods reach Running state | `kubectl get pods` shows Running |
| SC-08 | Backend health endpoint responds 200 | `curl /health` returns 200 |
| SC-09 | Frontend loads in browser | Navigate to localhost:30080 |
| SC-10 | User can register and login | Complete auth flow |
| SC-11 | User can create and view tasks | CRUD operations work |
| SC-12 | Chatbot responds to messages | AI integration functional |

### 15.2 Should-Have Criteria

| ID | Criterion | Verification Method |
|----|-----------|---------------------|
| SC-13 | Container images under size limits | `docker images` shows sizes |
| SC-14 | Pods start within 90 seconds | Observe startup time |
| SC-15 | Helm values are configurable | Test with custom values |
| SC-16 | Deployment can be upgraded | `helm upgrade` works |
| SC-17 | Deployment can be rolled back | `helm rollback` works |

### 15.3 Nice-to-Have Criteria

| ID | Criterion | Verification Method |
|----|-----------|---------------------|
| SC-18 | AI tools (Gordon, kubectl-ai) used successfully | Command execution logs |
| SC-19 | Zero-downtime rolling updates | No errors during upgrade |
| SC-20 | Resource limits respected | `kubectl top pods` shows limits |

---

## 16. Final Deliverables

### 16.1 Docker Artifacts

```
docker/
├── backend/
│   ├── Dockerfile              # Multi-stage FastAPI Dockerfile
│   └── .dockerignore           # Build exclusions
├── frontend/
│   ├── Dockerfile              # Multi-stage Next.js Dockerfile
│   └── .dockerignore           # Build exclusions
└── docker-compose.yml          # Optional: local testing compose
```

### 16.2 Helm Chart Artifacts

```
helm-charts/
├── todo-backend/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-local.yaml       # Local override values
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── configmap.yaml
│       ├── secret.yaml
│       └── NOTES.txt
├── todo-frontend/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-local.yaml       # Local override values
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── configmap.yaml
│       ├── ingress.yaml
│       └── NOTES.txt
└── README.md                   # Helm charts documentation
```

### 16.3 Deployment Scripts

```
scripts/
├── setup-minikube.sh           # Minikube initialization
├── build-images.sh             # Docker image build script
├── deploy.sh                   # Full deployment script
├── undeploy.sh                 # Cleanup script
├── port-forward.sh             # Port forwarding helper
└── validate.sh                 # Deployment validation script
```

### 16.4 Documentation

```
docs/
├── DEPLOYMENT-GUIDE.md         # Step-by-step deployment instructions
├── TROUBLESHOOTING.md          # Common issues and solutions
├── AI-TOOLS-GUIDE.md           # Using Gordon, kubectl-ai, kagent
└── ARCHITECTURE.md             # Deployment architecture details
```

### 16.5 Configuration Files

```
config/
├── namespace.yaml              # Kubernetes namespace definition
├── secrets-template.yaml       # Template for secrets (no actual values)
└── local-env.example           # Example environment variables
```

---

## 17. Implementation Phases

### Phase 1: Environment Setup
- Verify Docker Desktop installation
- Install/Start Minikube
- Configure kubectl context
- Install Helm
- Verify AI tools availability (Gordon, kubectl-ai, kagent)

### Phase 2: Containerization
- Create backend Dockerfile
- Create frontend Dockerfile
- Build and test images locally
- Load images into Minikube

### Phase 3: Helm Chart Development
- Create backend Helm chart structure
- Create frontend Helm chart structure
- Define values and templates
- Validate charts with `helm lint`

### Phase 4: Deployment
- Create namespace
- Deploy secrets and configmaps
- Deploy backend via Helm
- Deploy frontend via Helm
- Configure service exposure

### Phase 5: Validation
- Verify pod health
- Test API endpoints
- Test frontend functionality
- Validate full user flow

### Phase 6: Documentation
- Document deployment process
- Create troubleshooting guide
- Record AI tool usage patterns

---

## 18. Risk Assessment

### 18.1 Technical Risks

| ID | Risk | Probability | Impact | Mitigation |
|----|------|-------------|--------|------------|
| R-01 | Minikube resource constraints | Medium | High | Document minimum requirements |
| R-02 | Image build failures | Low | Medium | Provide detailed Dockerfiles |
| R-03 | Network connectivity issues | Medium | High | Document CORS and DNS config |
| R-04 | External API unreachable from cluster | Low | High | Test connectivity early |
| R-05 | AI tools unavailable | Medium | Low | Provide CLI fallback commands |

### 18.2 Operational Risks

| ID | Risk | Probability | Impact | Mitigation |
|----|------|-------------|--------|------------|
| R-06 | Configuration drift | Medium | Medium | Use version-controlled Helm values |
| R-07 | Secret exposure | Low | High | Use Kubernetes secrets, document best practices |
| R-08 | Resource exhaustion | Medium | Medium | Set resource limits in pods |

---

## Appendix A: Command Reference

### Minikube Commands
```bash
# Start Minikube
minikube start --driver=docker --memory=4096 --cpus=4

# Use Minikube Docker daemon
eval $(minikube docker-env)  # Linux/Mac
minikube docker-env | Invoke-Expression  # Windows PowerShell

# Get Minikube IP
minikube ip

# Access service
minikube service todo-frontend-svc -n todo-chatbot
```

### Docker Commands
```bash
# Build images (from Minikube Docker context)
docker build -t todo-backend:latest ./docker/backend
docker build -t todo-frontend:latest ./docker/frontend

# Or load pre-built images
minikube image load todo-backend:latest
minikube image load todo-frontend:latest
```

### Helm Commands
```bash
# Install charts
helm install todo-backend ./helm-charts/todo-backend -n todo-chatbot
helm install todo-frontend ./helm-charts/todo-frontend -n todo-chatbot

# Upgrade
helm upgrade todo-backend ./helm-charts/todo-backend -n todo-chatbot

# Rollback
helm rollback todo-backend 1 -n todo-chatbot

# Uninstall
helm uninstall todo-backend -n todo-chatbot
helm uninstall todo-frontend -n todo-chatbot
```

### kubectl Commands
```bash
# Create namespace
kubectl create namespace todo-chatbot

# View resources
kubectl get all -n todo-chatbot

# View logs
kubectl logs -f deployment/todo-backend -n todo-chatbot

# Port forward (alternative access)
kubectl port-forward svc/todo-frontend-svc 3000:80 -n todo-chatbot
kubectl port-forward svc/todo-backend-svc 8000:8000 -n todo-chatbot
```

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| ConfigMap | Kubernetes resource for non-sensitive configuration |
| ClusterIP | Internal-only Kubernetes service type |
| Helm | Kubernetes package manager using charts |
| Minikube | Local Kubernetes cluster for development |
| NodePort | Service type exposing a port on all nodes |
| Pod | Smallest deployable unit in Kubernetes |
| Secret | Kubernetes resource for sensitive data |
| Service | Kubernetes abstraction for exposing pods |

---

**Document End**

*This specification was generated by Claude Code as part of the Phase IV Local Kubernetes Deployment initiative. All artifacts described herein will be AI-generated in compliance with the project requirements.*
