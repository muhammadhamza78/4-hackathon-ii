# Phase IV - Architecture Documentation

This document describes the architecture of the Todo Chatbot Kubernetes deployment.

## Table of Contents

1. [System Overview](#system-overview)
2. [Component Architecture](#component-architecture)
3. [Container Architecture](#container-architecture)
4. [Kubernetes Architecture](#kubernetes-architecture)
5. [Networking](#networking)
6. [Data Flow](#data-flow)
7. [Security](#security)

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              HOST MACHINE                                    │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                         MINIKUBE CLUSTER                                │ │
│  │                                                                          │ │
│  │  ┌────────────────────────────────────────────────────────────────┐    │ │
│  │  │                 NAMESPACE: todo-chatbot                         │    │ │
│  │  │                                                                  │    │ │
│  │  │   ┌─────────────────┐           ┌─────────────────┐            │    │ │
│  │  │   │   FRONTEND      │           │    BACKEND      │            │    │ │
│  │  │   │   (Next.js)     │ ───────►  │   (FastAPI)     │            │    │ │
│  │  │   │   Port: 3000    │   HTTP    │   Port: 8000    │            │    │ │
│  │  │   └────────┬────────┘           └────────┬────────┘            │    │ │
│  │  │            │                             │                      │    │ │
│  │  │   ┌────────▼────────┐           ┌────────▼────────┐            │    │ │
│  │  │   │    Service      │           │    Service      │            │    │ │
│  │  │   │   NodePort      │           │   ClusterIP     │            │    │ │
│  │  │   │   :30080        │           │   :8000         │            │    │ │
│  │  │   └─────────────────┘           └─────────────────┘            │    │ │
│  │  │                                                                  │    │ │
│  │  │   ┌─────────────────────────────────────────────────────────┐  │    │ │
│  │  │   │              ConfigMaps & Secrets                        │  │    │ │
│  │  │   └─────────────────────────────────────────────────────────┘  │    │ │
│  │  └────────────────────────────────────────────────────────────────┘    │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                         │
│                          Browser Access                                      │
│                     http://localhost:30080                                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     │ HTTPS (External)
                                     ▼
                  ┌──────────────────────────────────────┐
                  │         EXTERNAL SERVICES            │
                  │                                      │
                  │  ┌────────────────────────────────┐  │
                  │  │   Neon PostgreSQL (Database)   │  │
                  │  └────────────────────────────────┘  │
                  │                                      │
                  │  ┌────────────────────────────────┐  │
                  │  │   Groq/OpenAI/Anthropic (AI)   │  │
                  │  └────────────────────────────────┘  │
                  └──────────────────────────────────────┘
```

---

## Component Architecture

### Frontend (Next.js)

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND CONTAINER                        │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Next.js 16                        │   │
│  │                                                       │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │   │
│  │  │    Pages    │  │  Components │  │     API     │  │   │
│  │  │             │  │             │  │   Routes    │  │   │
│  │  │ - Dashboard │  │ - TaskList  │  │             │  │   │
│  │  │ - Login     │  │ - ChatBox   │  │ - /auth     │  │   │
│  │  │ - Register  │  │ - Profile   │  │             │  │   │
│  │  │ - Tasks     │  │ - Theme     │  │             │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │   │
│  │                                                       │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │                   Libraries                      │ │   │
│  │  │  - React 19       - Tailwind CSS                 │ │   │
│  │  │  - TypeScript     - JWT Auth                     │ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Port: 3000                                                  │
│  User: nextjs (UID 1001)                                     │
└─────────────────────────────────────────────────────────────┘
```

### Backend (FastAPI)

```
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND CONTAINER                         │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   FastAPI 0.115+                     │   │
│  │                                                       │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │   │
│  │  │     API     │  │   Models    │  │   Services  │  │   │
│  │  │   Routes    │  │             │  │             │  │   │
│  │  │             │  │ - User      │  │ - Auth      │  │   │
│  │  │ - /auth     │  │ - Task      │  │ - Task      │  │   │
│  │  │ - /tasks    │  │ - Convo     │  │ - Chat      │  │   │
│  │  │ - /chat     │  │             │  │ - AI Agent  │  │   │
│  │  │ - /profile  │  │             │  │             │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │   │
│  │                                                       │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │                   Libraries                      │ │   │
│  │  │  - SQLModel       - Pydantic                     │ │   │
│  │  │  - python-jose    - bcrypt                       │ │   │
│  │  │  - Groq/OpenAI    - psycopg                      │ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Port: 8000                                                  │
│  User: appuser (UID 1001)                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Container Architecture

### Multi-Stage Build Process

```
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND BUILD                             │
│                                                              │
│  Stage 1: Builder                    Stage 2: Production     │
│  ┌─────────────────────┐            ┌─────────────────────┐ │
│  │ python:3.11-slim    │            │ python:3.11-slim    │ │
│  │                     │            │                     │ │
│  │ - Install gcc       │            │ - Copy venv         │ │
│  │ - Create venv       │ ────────►  │ - Copy app code     │ │
│  │ - pip install       │            │ - Non-root user     │ │
│  │ - requirements.txt  │            │ - Health check      │ │
│  └─────────────────────┘            └─────────────────────┘ │
│                                                              │
│  Result: ~200MB optimized image                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND BUILD                            │
│                                                              │
│  Stage 1: Deps         Stage 2: Builder    Stage 3: Runner  │
│  ┌──────────────┐     ┌──────────────┐    ┌──────────────┐ │
│  │ node:20-alpine│     │ node:20-alpine│    │ node:20-alpine│ │
│  │              │     │              │    │              │ │
│  │ - npm ci     │────►│ - Copy deps  │───►│ - Standalone │ │
│  │ - node_modules│     │ - npm build  │    │ - Non-root   │ │
│  └──────────────┘     └──────────────┘    └──────────────┘ │
│                                                              │
│  Result: ~150MB optimized image                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Kubernetes Architecture

### Resource Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                        │
│                                                              │
│  Namespace: todo-chatbot                                     │
│  │                                                           │
│  ├── Deployments                                             │
│  │   ├── todo-backend                                        │
│  │   │   └── ReplicaSet                                      │
│  │   │       └── Pod(s)                                      │
│  │   │           └── Container: backend                      │
│  │   │                                                       │
│  │   └── todo-frontend                                       │
│  │       └── ReplicaSet                                      │
│  │           └── Pod(s)                                      │
│  │               └── Container: frontend                     │
│  │                                                           │
│  ├── Services                                                │
│  │   ├── todo-backend-svc (ClusterIP)                        │
│  │   │   └── Port: 8000 → 8000                               │
│  │   │                                                       │
│  │   └── todo-frontend-svc (NodePort)                        │
│  │       └── Port: 80 → 3000, NodePort: 30080                │
│  │                                                           │
│  ├── ConfigMaps                                              │
│  │   ├── todo-backend-config                                 │
│  │   │   └── CORS_ORIGINS, DEBUG, AI_PROVIDER                │
│  │   │                                                       │
│  │   └── todo-frontend-config                                │
│  │       └── NEXT_PUBLIC_API_URL                             │
│  │                                                           │
│  ├── Secrets                                                 │
│  │   └── todo-backend-secrets                                │
│  │       └── DATABASE_URL, JWT_SECRET_KEY, GROQ_API_KEY      │
│  │                                                           │
│  └── ServiceAccounts                                         │
│      ├── todo-backend                                        │
│      └── todo-frontend                                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Helm Chart Structure

```
helm-charts/
├── todo-backend/
│   ├── Chart.yaml              # Chart metadata
│   ├── values.yaml             # Default configuration
│   ├── .helmignore             # Files to ignore
│   └── templates/
│       ├── _helpers.tpl        # Template helpers
│       ├── deployment.yaml     # Deployment resource
│       ├── service.yaml        # Service resource
│       ├── configmap.yaml      # ConfigMap resource
│       ├── secret.yaml         # Secret resource
│       ├── serviceaccount.yaml # ServiceAccount
│       ├── hpa.yaml            # HorizontalPodAutoscaler
│       └── NOTES.txt           # Post-install notes
│
└── todo-frontend/
    ├── Chart.yaml
    ├── values.yaml
    ├── .helmignore
    └── templates/
        ├── _helpers.tpl
        ├── deployment.yaml
        ├── service.yaml
        ├── configmap.yaml
        ├── serviceaccount.yaml
        ├── ingress.yaml        # Optional Ingress
        ├── hpa.yaml
        └── NOTES.txt
```

---

## Networking

### Service Communication

```
┌──────────────────────────────────────────────────────────────┐
│                    CLUSTER NETWORK                            │
│                                                               │
│  External                                                     │
│  ────────────────────────────────────────────────────────    │
│       │                                                       │
│       │ NodePort :30080                                       │
│       ▼                                                       │
│  ┌──────────────────────┐                                    │
│  │  todo-frontend-svc   │                                    │
│  │  (NodePort)          │                                    │
│  │  :80 → :3000         │                                    │
│  └──────────┬───────────┘                                    │
│             │                                                 │
│             │ Internal Cluster Network                        │
│             ▼                                                 │
│  ┌──────────────────────┐      ┌──────────────────────┐     │
│  │  Frontend Pod        │      │  todo-backend-svc    │     │
│  │                      │─────►│  (ClusterIP)         │     │
│  │  Calls:              │      │  :8000 → :8000       │     │
│  │  http://todo-backend │      └──────────┬───────────┘     │
│  │  -svc:8000           │                 │                  │
│  └──────────────────────┘                 ▼                  │
│                               ┌──────────────────────┐       │
│                               │  Backend Pod         │       │
│                               │                      │       │
│                               │  Serves API on :8000 │       │
│                               └──────────────────────┘       │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### DNS Resolution

| Service | DNS Name | Full DNS |
|---------|----------|----------|
| Backend | `todo-backend-svc` | `todo-backend-svc.todo-chatbot.svc.cluster.local` |
| Frontend | `todo-frontend-svc` | `todo-frontend-svc.todo-chatbot.svc.cluster.local` |

---

## Data Flow

### Request Flow

```
┌─────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│User │────►│ Browser  │────►│ Frontend │────►│ Backend  │────►│ Database │
│     │     │          │     │ (Next.js)│     │ (FastAPI)│     │  (Neon)  │
└─────┘     └──────────┘     └──────────┘     └──────────┘     └──────────┘
                                   │               │
                                   │               │
                                   │               ▼
                                   │         ┌──────────┐
                                   │         │   AI     │
                                   │         │  (Groq)  │
                                   │         └──────────┘
                                   │
                                   ▼
                             ┌──────────┐
                             │  Static  │
                             │  Assets  │
                             └──────────┘
```

### Authentication Flow

```
1. User Login Request
   Browser → Frontend → Backend → Database
                              ↓
                         Verify Password
                              ↓
                         Generate JWT
                              ↓
2. JWT Response
   Browser ← Frontend ← Backend
       ↓
   Store in localStorage

3. Authenticated Request
   Browser → Frontend → Backend (with JWT header)
                              ↓
                         Verify JWT
                              ↓
                         Process Request
                              ↓
   Browser ← Frontend ← Backend (Response)
```

---

## Security

### Container Security

| Security Feature | Backend | Frontend |
|-----------------|---------|----------|
| Non-root user | appuser (1001) | nextjs (1001) |
| Read-only filesystem | Configurable | Configurable |
| Dropped capabilities | ALL | ALL |
| No privilege escalation | Yes | Yes |

### Kubernetes Security

```yaml
# Pod Security Context
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  runAsGroup: 1001
  fsGroup: 1001

# Container Security Context
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  capabilities:
    drop:
      - ALL
```

### Secret Management

```
┌─────────────────────────────────────────────────────────────┐
│                    SECRET HANDLING                           │
│                                                              │
│  1. Secrets created via Helm                                 │
│     helm --set secrets.databaseUrl="..."                     │
│                                                              │
│  2. Stored as Kubernetes Secret                              │
│     kubectl get secret todo-backend-secrets                  │
│                                                              │
│  3. Injected as environment variables                        │
│     envFrom:                                                 │
│       - secretRef:                                           │
│           name: todo-backend-secrets                         │
│                                                              │
│  4. Available in container                                   │
│     $DATABASE_URL, $JWT_SECRET_KEY, $GROQ_API_KEY            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Summary

| Component | Technology | Port | Replicas |
|-----------|------------|------|----------|
| Frontend | Next.js 16 | 3000 | 1 |
| Backend | FastAPI | 8000 | 1 |
| Database | PostgreSQL (Neon) | 5432 | External |
| AI | Groq API | 443 | External |

| Kubernetes Resource | Backend | Frontend |
|--------------------|---------|----------|
| Deployment | todo-backend | todo-frontend |
| Service | ClusterIP:8000 | NodePort:30080 |
| ConfigMap | todo-backend-config | todo-frontend-config |
| Secret | todo-backend-secrets | - |
