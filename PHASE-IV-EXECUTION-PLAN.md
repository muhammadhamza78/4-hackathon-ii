# Phase IV — High-Level Execution Plan

**Document Version:** 1.0
**Date:** 2026-01-18
**Status:** Planning

---

## 1. Context Summary

### 1.1 Project Overview
Phase IV delivers a local Kubernetes deployment of the Phase III Todo Chatbot application. The application consists of:

| Component | Technology | Port | Status |
|-----------|------------|------|--------|
| Frontend | Next.js 16.1.1, React 19, TypeScript | 3000 | Existing code ready |
| Backend | FastAPI 0.115.0+, SQLModel, JWT auth | 8000 | Existing code ready |
| Database | PostgreSQL (Neon serverless) | N/A | External, pre-configured |
| AI Integration | Groq/OpenAI/Anthropic APIs | N/A | External, pre-configured |

### 1.2 Deployment Target
- **Platform:** Minikube (local Kubernetes cluster)
- **Container Runtime:** Docker Desktop
- **Package Manager:** Helm 3.x
- **Namespace:** `todo-chatbot`

### 1.3 Key Constraint
All artifacts (Dockerfiles, Helm charts, scripts) must be AI-generated. No manual coding permitted.

---

## 2. Execution Phases

### Phase 1: PREPARE
**Objective:** Establish a verified, operational infrastructure foundation

| Step | Action | Tool(s) | Output |
|------|--------|---------|--------|
| 1.1 | Verify Docker Desktop is running | CLI check | Confirmation |
| 1.2 | Start Minikube cluster with recommended resources | `minikube start` | Running cluster |
| 1.3 | Configure Docker to use Minikube daemon | `minikube docker-env` | Environment set |
| 1.4 | Verify kubectl context points to Minikube | `kubectl config current-context` | Correct context |
| 1.5 | Confirm Helm installation | `helm version` | Version confirmed |
| 1.6 | Verify AI tool availability | Gordon, kubectl-ai, kagent checks | Tool inventory |
| 1.7 | Create `todo-chatbot` namespace | `kubectl create namespace` | Namespace created |

**Transition Condition:** All infrastructure components verified and namespace exists.

---

### Phase 2: CONTAINERIZE
**Objective:** Create production-ready Docker images for both services

| Step | Action | Tool(s) | Output |
|------|--------|---------|--------|
| 2.1 | Create backend Dockerfile (multi-stage) | Gordon (AI-assist) | `docker/backend/Dockerfile` |
| 2.2 | Create backend .dockerignore | Gordon | `docker/backend/.dockerignore` |
| 2.3 | Build backend image | `docker build` | `todo-backend:latest` |
| 2.4 | Verify backend image runs locally | `docker run` health check | Container healthy |
| 2.5 | Create frontend Dockerfile (multi-stage) | Gordon (AI-assist) | `docker/frontend/Dockerfile` |
| 2.6 | Create frontend .dockerignore | Gordon | `docker/frontend/.dockerignore` |
| 2.7 | Build frontend image | `docker build` | `todo-frontend:latest` |
| 2.8 | Verify frontend image runs locally | `docker run` port check | Container serves |
| 2.9 | Verify images in Minikube registry | `minikube image ls` | Both images listed |

**Transition Condition:** Both images build successfully, pass health checks, and are accessible to Minikube.

---

### Phase 3: PACKAGE
**Objective:** Create Helm charts for Kubernetes resource management

| Step | Action | Tool(s) | Output |
|------|--------|---------|--------|
| 3.1 | Scaffold backend Helm chart structure | kubectl-ai / manual | `helm-charts/todo-backend/` |
| 3.2 | Create backend Chart.yaml | kubectl-ai | Chart metadata |
| 3.3 | Create backend values.yaml | kubectl-ai | Default values |
| 3.4 | Create backend deployment.yaml template | kubectl-ai | Deployment resource |
| 3.5 | Create backend service.yaml template | kubectl-ai | ClusterIP service |
| 3.6 | Create backend configmap.yaml template | kubectl-ai | Non-sensitive config |
| 3.7 | Create backend secret.yaml template | kubectl-ai | Sensitive config |
| 3.8 | Create backend _helpers.tpl | kubectl-ai | Template helpers |
| 3.9 | Validate backend chart | `helm lint` | No errors |
| 3.10 | Scaffold frontend Helm chart structure | kubectl-ai / manual | `helm-charts/todo-frontend/` |
| 3.11 | Create frontend Chart.yaml | kubectl-ai | Chart metadata |
| 3.12 | Create frontend values.yaml | kubectl-ai | Default values |
| 3.13 | Create frontend deployment.yaml template | kubectl-ai | Deployment resource |
| 3.14 | Create frontend service.yaml (NodePort) | kubectl-ai | External access |
| 3.15 | Create frontend configmap.yaml template | kubectl-ai | API URL config |
| 3.16 | Create frontend _helpers.tpl | kubectl-ai | Template helpers |
| 3.17 | Validate frontend chart | `helm lint` | No errors |
| 3.18 | Dry-run both charts | `helm template` | Valid YAML output |

**Transition Condition:** Both charts pass `helm lint` and `helm template` without errors.

---

### Phase 4: DEPLOY
**Objective:** Deploy the complete application stack to Minikube

| Step | Action | Tool(s) | Output |
|------|--------|---------|--------|
| 4.1 | Prepare secrets file with base64-encoded values | Manual/script | `secrets.yaml` ready |
| 4.2 | Deploy backend Helm chart | kagent / `helm install` | Release created |
| 4.3 | Wait for backend pods to be Ready | `kubectl wait` | Pods running |
| 4.4 | Verify backend health endpoint | `kubectl exec` curl | 200 OK |
| 4.5 | Deploy frontend Helm chart | kagent / `helm install` | Release created |
| 4.6 | Wait for frontend pods to be Ready | `kubectl wait` | Pods running |
| 4.7 | Expose frontend via NodePort/tunnel | `minikube service` | URL available |
| 4.8 | Verify frontend is accessible | Browser/curl | Page loads |

**Transition Condition:** Both services deployed, pods in Running state, services accessible.

---

### Phase 5: VALIDATE
**Objective:** Confirm full application functionality in Kubernetes

| Step | Action | Tool(s) | Output |
|------|--------|---------|--------|
| 5.1 | Verify frontend-to-backend connectivity | Browser network tab | API calls succeed |
| 5.2 | Test user registration | UI test | New user created |
| 5.3 | Test user login | UI test | JWT token received |
| 5.4 | Test task creation | UI test | Task persisted |
| 5.5 | Test task listing | UI test | Tasks displayed |
| 5.6 | Test task completion | UI test | Status updated |
| 5.7 | Test chatbot interaction | UI test | AI responds |
| 5.8 | Verify logs for errors | `kubectl logs` | No critical errors |
| 5.9 | Check resource usage | `kubectl top pods` | Within limits |
| 5.10 | Test Helm upgrade | `helm upgrade` | Rolling update works |
| 5.11 | Test Helm rollback | `helm rollback` | Previous version restored |

**Transition Condition:** All user flows work, no errors in logs, resources within limits.

---

### Phase 6: DOCUMENT
**Objective:** Capture deployment procedures and operational knowledge

| Step | Action | Tool(s) | Output |
|------|--------|---------|--------|
| 6.1 | Create DEPLOYMENT-GUIDE.md | Documentation | Step-by-step instructions |
| 6.2 | Create TROUBLESHOOTING.md | Documentation | Common issues/solutions |
| 6.3 | Create AI-TOOLS-GUIDE.md | Documentation | Gordon/kubectl-ai/kagent usage |
| 6.4 | Update README.md | Documentation | Project overview |
| 6.5 | Create deployment scripts | Scripting | `scripts/deploy.sh`, etc. |
| 6.6 | Record AI tool usage patterns | Documentation | Lessons learned |

**Transition Condition:** All documentation complete and reviewed.

---

## 3. Dependencies

### 3.1 Inter-Phase Dependencies

```
Phase 1 (PREPARE)
    │
    ▼
Phase 2 (CONTAINERIZE)
    │
    ├──► Requires: Docker daemon from Phase 1
    │
    ▼
Phase 3 (PACKAGE)
    │
    ├──► Requires: Image names/tags from Phase 2
    │
    ▼
Phase 4 (DEPLOY)
    │
    ├──► Requires: Charts from Phase 3
    ├──► Requires: Images from Phase 2
    ├──► Requires: Namespace from Phase 1
    │
    ▼
Phase 5 (VALIDATE)
    │
    ├──► Requires: Running deployments from Phase 4
    │
    ▼
Phase 6 (DOCUMENT)
    │
    ├──► Requires: Validated deployment from Phase 5
```

### 3.2 External Dependencies

| Dependency | Type | Critical | Fallback |
|------------|------|----------|----------|
| Neon PostgreSQL | Database service | Yes | None (must be reachable) |
| Groq/AI API | AI service | Yes | Alternative AI providers |
| Docker Desktop | Container runtime | Yes | None |
| Internet connectivity | Network | Yes | Cache images locally |

### 3.3 Tool Dependencies

| Tool | Depends On | Purpose |
|------|------------|---------|
| kubectl | Minikube running | Cluster operations |
| Helm | kubectl configured | Chart deployment |
| Gordon | Docker running | AI-assisted Docker ops |
| kubectl-ai | kubectl configured | AI-assisted k8s ops |
| kagent | Helm + kubectl | Automated deployments |

---

## 4. Tooling Usage

### 4.1 Gordon (Docker AI)

**Use Cases:**
| Scenario | Example Command | Phase |
|----------|-----------------|-------|
| Dockerfile generation | `docker ai "create multi-stage Dockerfile for FastAPI"` | CONTAINERIZE |
| Image optimization | `docker ai "optimize this Dockerfile for size"` | CONTAINERIZE |
| Build troubleshooting | `docker ai "why is my build failing at layer 5"` | CONTAINERIZE |
| Container debugging | `docker ai "why won't my container start"` | CONTAINERIZE |

**Fallback:** Standard Docker CLI commands.

### 4.2 kubectl-ai

**Use Cases:**
| Scenario | Example Command | Phase |
|----------|-----------------|-------|
| Resource generation | `kubectl-ai "create deployment for backend with health checks"` | PACKAGE |
| Service creation | `kubectl-ai "expose backend on ClusterIP port 8000"` | PACKAGE |
| Debugging | `kubectl-ai "show me why pods are in CrashLoopBackOff"` | DEPLOY |
| Log analysis | `kubectl-ai "get logs from backend pods with errors"` | VALIDATE |
| Status check | `kubectl-ai "show all resources in todo-chatbot namespace"` | VALIDATE |

**Fallback:** Standard kubectl commands.

### 4.3 kagent

**Use Cases:**
| Scenario | Example Command | Phase |
|----------|-----------------|-------|
| Chart deployment | `kagent deploy --chart ./helm-charts/todo-backend` | DEPLOY |
| Health monitoring | `kagent health --namespace todo-chatbot` | VALIDATE |
| Status overview | `kagent status --all` | VALIDATE |
| Rollback | `kagent rollback --deployment todo-backend` | VALIDATE |
| Diagnostics | `kagent diagnose --pod <pod-name>` | VALIDATE |

**Fallback:** Standard Helm + kubectl commands.

### 4.4 Tool Decision Matrix

| Task | Preferred Tool | Fallback Tool |
|------|----------------|---------------|
| Write Dockerfile | Gordon | Manual vim/nano |
| Build image | docker build | N/A |
| Generate K8s YAML | kubectl-ai | Manual creation |
| Deploy Helm chart | kagent | helm install |
| Debug pod issues | kagent diagnose | kubectl describe/logs |
| Rollback deployment | kagent rollback | helm rollback |

---

## 5. Transition Conditions

### 5.1 Phase Gate Criteria

| From | To | Gate Criteria |
|------|----|---------------|
| - | PREPARE | Project directory exists, spec reviewed |
| PREPARE | CONTAINERIZE | Minikube running, namespace created, all tools verified |
| CONTAINERIZE | PACKAGE | Both images built, pass health checks, loaded in Minikube |
| PACKAGE | DEPLOY | Both charts pass `helm lint` and `helm template` |
| DEPLOY | VALIDATE | All pods Running, services accessible |
| VALIDATE | DOCUMENT | All functional tests pass, no critical errors |
| DOCUMENT | COMPLETE | All docs created, scripts tested |

### 5.2 Rollback Triggers

| Phase | Condition | Action |
|-------|-----------|--------|
| CONTAINERIZE | Image build fails 3x | Review Dockerfile, check base image |
| PACKAGE | Helm lint fails | Fix template syntax errors |
| DEPLOY | Pods in CrashLoopBackOff | Check logs, verify secrets, rollback if needed |
| DEPLOY | Services not responding | Check service selectors, port mappings |
| VALIDATE | API calls fail | Check CORS, network policies, DNS |

---

## 6. Risks and Mitigations

### 6.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **R-01:** Minikube resource constraints (OOM, CPU throttling) | Medium | High | Start with `--memory=4096 --cpus=4`; document minimum requirements |
| **R-02:** Docker image build failures | Low | Medium | Use verified base images; test builds incrementally |
| **R-03:** Frontend-backend network issues in cluster | Medium | High | Validate CORS config early; test with curl from within cluster |
| **R-04:** External APIs unreachable from pods | Low | High | Test internet access from pod early; configure DNS if needed |
| **R-05:** AI tools (Gordon/kubectl-ai) unavailable | Medium | Low | Document manual CLI fallback commands |
| **R-06:** Next.js build-time env vars not injecting | Medium | Medium | Use runtime env injection or build args |
| **R-07:** Secret values not base64 encoded correctly | Low | Medium | Provide encoding script; validate early |
| **R-08:** Health probes misconfigured | Medium | Medium | Test probes independently before deployment |

### 6.2 Operational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **R-09:** Configuration drift between local and Helm values | Medium | Medium | Single source of truth in values.yaml |
| **R-10:** Secrets accidentally committed to git | Low | High | Use .gitignore for secrets; use secret templates |
| **R-11:** Resource exhaustion in local Minikube | Medium | Medium | Set resource limits; monitor with `kubectl top` |

### 6.3 Risk Response Plan

```
IF Minikube won't start:
  → Check Docker Desktop running
  → Delete and recreate: minikube delete && minikube start

IF Image build fails:
  → Check Dockerfile syntax with Gordon
  → Verify source files exist
  → Check .dockerignore not excluding needed files

IF Pods stuck in Pending:
  → Check resource requests vs. available
  → Run: kubectl describe pod <name>

IF CrashLoopBackOff:
  → Check logs: kubectl logs <pod>
  → Verify secrets are mounted correctly
  → Check health probe paths exist

IF Services not accessible:
  → Verify selector matches pod labels
  → Check NodePort is in valid range (30000-32767)
  → Run: minikube service <name> --url
```

---

## 7. Completion Definition

### 7.1 Must-Have (MVP) Criteria

Phase IV is **COMPLETE** when all of the following are verified:

| ID | Criterion | Verification |
|----|-----------|--------------|
| C-01 | Backend Docker image builds without errors | `docker build` exit code 0 |
| C-02 | Frontend Docker image builds without errors | `docker build` exit code 0 |
| C-03 | Images are accessible in Minikube | `minikube image ls` shows both |
| C-04 | Backend Helm chart deploys successfully | `helm install` exit code 0 |
| C-05 | Frontend Helm chart deploys successfully | `helm install` exit code 0 |
| C-06 | Backend pods are Running (1/1 Ready) | `kubectl get pods` |
| C-07 | Frontend pods are Running (1/1 Ready) | `kubectl get pods` |
| C-08 | Backend /health returns 200 | curl test |
| C-09 | Frontend loads in browser | Navigate to `localhost:30080` |
| C-10 | User can register a new account | Complete registration flow |
| C-11 | User can log in | Complete login flow |
| C-12 | User can create a task | Add task via UI |
| C-13 | User can view tasks | Tasks display correctly |
| C-14 | Chatbot responds to messages | Send message, receive response |

### 7.2 Should-Have Criteria

| ID | Criterion | Verification |
|----|-----------|--------------|
| S-01 | Backend image < 500MB | `docker images` size check |
| S-02 | Frontend image < 1GB | `docker images` size check |
| S-03 | Pods start within 90 seconds | Observe startup time |
| S-04 | `helm upgrade` works | Successful upgrade |
| S-05 | `helm rollback` works | Successful rollback |
| S-06 | All deployment scripts work | Run each script |
| S-07 | Documentation is complete | Review all docs |

### 7.3 Nice-to-Have Criteria

| ID | Criterion | Verification |
|----|-----------|--------------|
| N-01 | AI tools used for >50% of operations | Usage log |
| N-02 | Zero-downtime rolling updates | No errors during upgrade |
| N-03 | Resource limits are respected | `kubectl top pods` |

### 7.4 Deliverables Checklist

```
docker/
├── [  ] backend/Dockerfile
├── [  ] backend/.dockerignore
├── [  ] frontend/Dockerfile
└── [  ] frontend/.dockerignore

helm-charts/
├── todo-backend/
│   ├── [  ] Chart.yaml
│   ├── [  ] values.yaml
│   └── templates/
│       ├── [  ] deployment.yaml
│       ├── [  ] service.yaml
│       ├── [  ] configmap.yaml
│       ├── [  ] secret.yaml
│       └── [  ] _helpers.tpl
└── todo-frontend/
    ├── [  ] Chart.yaml
    ├── [  ] values.yaml
    └── templates/
        ├── [  ] deployment.yaml
        ├── [  ] service.yaml
        ├── [  ] configmap.yaml
        └── [  ] _helpers.tpl

scripts/
├── [  ] setup-minikube.sh (or .ps1)
├── [  ] build-images.sh
├── [  ] deploy.sh
├── [  ] undeploy.sh
└── [  ] validate.sh

docs/
├── [  ] DEPLOYMENT-GUIDE.md
├── [  ] TROUBLESHOOTING.md
└── [  ] AI-TOOLS-GUIDE.md
```

---

## 8. Summary

| Phase | Key Activities | Primary Tools | Exit Criteria |
|-------|----------------|---------------|---------------|
| **1. PREPARE** | Verify infra, start Minikube, create namespace | CLI, minikube | Cluster running, namespace exists |
| **2. CONTAINERIZE** | Write Dockerfiles, build images, verify | Gordon, Docker | Images built and healthy |
| **3. PACKAGE** | Create Helm charts, validate templates | kubectl-ai, Helm | Charts lint-clean |
| **4. DEPLOY** | Deploy charts, configure secrets, expose services | kagent, Helm | Pods running, services up |
| **5. VALIDATE** | Test all user flows, check logs, verify integration | kubectl, Browser | All tests pass |
| **6. DOCUMENT** | Write guides, create scripts, capture learnings | Text editor | Docs complete |

**Total Phases:** 6
**Critical Path:** PREPARE → CONTAINERIZE → PACKAGE → DEPLOY → VALIDATE
**Parallel Work:** DOCUMENT can begin during VALIDATE

---

*This execution plan was generated by Claude Code for Phase IV implementation.*
