# Phase IV Deployment Scripts

This directory contains scripts to execute the Phase IV - Local Kubernetes Deployment tasks.

## Available Scripts

1. `run-phase-iv-tasks.bat` - Batch script for Command Prompt
2. `run-phase-iv-tasks.ps1` - PowerShell script

## Prerequisites

Before running these scripts, ensure you have:

- Docker Desktop installed and running
- Minikube installed
- Helm installed
- kubectl installed
- Phase III Todo Chatbot source code in the `backend` and `frontend` directories

## How to Run

### Option 1: Using Command Prompt
```cmd
run-phase-iv-tasks.bat
```

### Option 2: Using PowerShell
```powershell
.\run-phase-iv-tasks.ps1
```

> **Note**: You may need to enable PowerShell script execution:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

## What the Scripts Do

The scripts will execute all 15 tasks of Phase IV in sequence:

1. Environment Setup and Verification
2. Docker AI Agent Availability Check
3. Source Code Preparation
4. Dockerfile Generation with Gordon (if available)
5. Dockerfile Generation Fallback (if Gordon unavailable)
6. Container Image Building
7. Container Testing
8. Helm Chart Creation
9. Helm Chart Validation
10. Minikube Cluster Initialization
11. Helm Deployment
12. Deployment Validation
13. Application Functionality Testing
14. Performance Validation
15. Documentation and Artifact Organization

Each task will pause for confirmation before proceeding to the next task.