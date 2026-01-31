# Phase IV: Claude-Executable Atomic Tasks

This directory contains the implementation of the Phase IV tasks for deploying the Todo Chatbot application to a local Kubernetes cluster using AI-assisted tools.

## Files Included

1. `PHASE-IV-ATOMIC-TASK-IMPLEMENTATION.md` - Detailed implementation plan for all 15 tasks
2. `run-phase-iv-atomic-tasks.sh` - Bash script to execute all tasks sequentially
3. `run-phase-iv-atomic-tasks.bat` - Windows batch script to execute all tasks sequentially
4. `phase-iv-completion-report.md` - Generated upon successful completion of all tasks
5. `docs/` - Directory containing operational playbooks

## Prerequisites

Before running the scripts, ensure you have:

- Docker Desktop installed and running
- Minikube installed and configured
- kubectl installed
- Helm installed
- (Optional) kubectl-ai and Kagent for AI-assisted operations
- (Optional) Docker AI Agent (Gordon) enabled in Docker Desktop settings

## How to Run

### On Linux/macOS:
```bash
chmod +x run-phase-iv-atomic-tasks.sh
./run-phase-iv-atomic-tasks.sh
```

### On Windows:
Double-click `run-phase-iv-atomic-tasks.bat` or run it from Command Prompt.

## Tasks Overview

The scripts will execute the following 15 tasks:

1. Initialize Local DevOps Runtime
2. Enable Docker AI Agent (Gordon)
3. Source Code Workspace Verification
4. Containerize Backend Using Gordon
5. Containerize Frontend Using Gordon
6. Local Docker Smoke Test
7. Generate Helm Chart Skeleton via AI
8. Add Minikube-Compatible Values
9. Deploy Backend via Helm
10. Deploy Frontend via Helm
11. Enable Ingress Routing on Minikube
12. Kubernetes AI-Ops Validation
13. Functional Test of Chatbot Application
14. Document Operational Playbooks
15. Phase-IV Final Review Deliverable

Each task will pause for confirmation before proceeding to the next task.

## Expected Outcome

Upon successful completion, you will have:

- Containerized backend and frontend applications
- Deployed both applications to a local Minikube cluster using Helm
- Configured ingress for external access
- Validated the deployment with functional tests
- Generated comprehensive documentation
- Created a completion report