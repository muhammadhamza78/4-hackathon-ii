#!/bin/bash
# ==============================================================================
# Phase IV - Kubernetes Deployment Script (Bash)
# ==============================================================================

set -e

# Default values
NAMESPACE="todo-chatbot"
BACKEND_RELEASE="todo-backend"
FRONTEND_RELEASE="todo-frontend"
DRY_RUN=false
SKIP_BACKEND=false
SKIP_FRONTEND=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace) NAMESPACE="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --skip-backend) SKIP_BACKEND=true; shift ;;
        --skip-frontend) SKIP_FRONTEND=true; shift ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "  -n, --namespace     Kubernetes namespace (default: todo-chatbot)"
            echo "  --dry-run           Print commands without executing"
            echo "  --skip-backend      Skip backend deployment"
            echo "  --skip-frontend     Skip frontend deployment"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Phase IV - Kubernetes Deployment${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"

if ! minikube status --format='{{.Host}}' 2>/dev/null | grep -q "Running"; then
    echo -e "${RED}  ERROR: Minikube is not running${NC}"
    echo -e "${YELLOW}  Run ./setup-minikube.sh first${NC}"
    exit 1
fi
echo -e "${GREEN}  Minikube is running${NC}"

if ! kubectl cluster-info &>/dev/null; then
    echo -e "${RED}  ERROR: kubectl cannot connect to cluster${NC}"
    exit 1
fi
echo -e "${GREEN}  kubectl connected to cluster${NC}"

if ! helm version &>/dev/null; then
    echo -e "${RED}  ERROR: Helm is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}  Helm is available${NC}"

# Configure Docker environment
echo -e "${YELLOW}[2/7] Configuring Docker environment...${NC}"
eval $(minikube docker-env)
echo -e "${GREEN}  Using Minikube's Docker daemon${NC}"

# Create namespace
echo -e "${YELLOW}[3/7] Creating namespace '$NAMESPACE'...${NC}"
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "  [DRY-RUN] Would create namespace: $NAMESPACE"
    else
        kubectl create namespace "$NAMESPACE"
        echo -e "${GREEN}  Namespace created${NC}"
    fi
else
    echo -e "${GREEN}  Namespace already exists${NC}"
fi

# Load secrets from .env file
echo -e "${YELLOW}[4/7] Configuring secrets...${NC}"
SECRETS_ARGS=""
ENV_FILE="$PROJECT_ROOT/backend/.env"

if [ -f "$ENV_FILE" ]; then
    echo "  Loading secrets from $ENV_FILE"

    DATABASE_URL=$(grep "^DATABASE_URL=" "$ENV_FILE" | cut -d'=' -f2-)
    JWT_SECRET=$(grep "^JWT_SECRET_KEY=" "$ENV_FILE" | cut -d'=' -f2-)
    GROQ_KEY=$(grep "^GROQ_API_KEY=" "$ENV_FILE" | cut -d'=' -f2-)

    [ -n "$DATABASE_URL" ] && SECRETS_ARGS="$SECRETS_ARGS --set secrets.databaseUrl=$DATABASE_URL"
    [ -n "$JWT_SECRET" ] && SECRETS_ARGS="$SECRETS_ARGS --set secrets.jwtSecretKey=$JWT_SECRET"
    [ -n "$GROQ_KEY" ] && SECRETS_ARGS="$SECRETS_ARGS --set secrets.groqApiKey=$GROQ_KEY"

    echo -e "${GREEN}  Secrets loaded from .env file${NC}"
else
    echo -e "${YELLOW}  WARNING: No .env file found${NC}"
fi

# Deploy Backend
if [ "$SKIP_BACKEND" = false ]; then
    echo -e "${YELLOW}[5/7] Deploying Backend...${NC}"

    HELM_CMD="helm upgrade --install $BACKEND_RELEASE $PROJECT_ROOT/helm-charts/todo-backend \
        -n $NAMESPACE \
        --set image.repository=todo-backend \
        --set image.tag=latest \
        --set image.pullPolicy=Never \
        $SECRETS_ARGS"

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] $HELM_CMD --dry-run"
        eval "$HELM_CMD --dry-run"
    else
        eval "$HELM_CMD"
    fi
    echo -e "${GREEN}  Backend deployed successfully${NC}"
else
    echo -e "${YELLOW}[5/7] Skipping Backend deployment...${NC}"
fi

# Deploy Frontend
if [ "$SKIP_FRONTEND" = false ]; then
    echo -e "${YELLOW}[6/7] Deploying Frontend...${NC}"

    HELM_CMD="helm upgrade --install $FRONTEND_RELEASE $PROJECT_ROOT/helm-charts/todo-frontend \
        -n $NAMESPACE \
        --set config.apiUrl=http://$BACKEND_RELEASE-svc:8000 \
        --set image.repository=todo-frontend \
        --set image.tag=latest \
        --set image.pullPolicy=Never"

    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] $HELM_CMD --dry-run"
        eval "$HELM_CMD --dry-run"
    else
        eval "$HELM_CMD"
    fi
    echo -e "${GREEN}  Frontend deployed successfully${NC}"
else
    echo -e "${YELLOW}[6/7] Skipping Frontend deployment...${NC}"
fi

# Wait for deployments
echo -e "${YELLOW}[7/7] Waiting for pods to be ready...${NC}"
if [ "$DRY_RUN" = false ]; then
    [ "$SKIP_BACKEND" = false ] && kubectl rollout status deployment/$BACKEND_RELEASE -n $NAMESPACE --timeout=120s
    [ "$SKIP_FRONTEND" = false ] && kubectl rollout status deployment/$FRONTEND_RELEASE -n $NAMESPACE --timeout=120s
fi

# Display status
echo ""
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Deployment Complete!${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

if [ "$DRY_RUN" = false ]; then
    echo -e "${YELLOW}Resources in namespace '$NAMESPACE':${NC}"
    kubectl get all -n $NAMESPACE
    echo ""

    MINIKUBE_IP=$(minikube ip)
    echo -e "${YELLOW}Access the application:${NC}"
    echo "  Frontend: http://$MINIKUBE_IP:30080"
    echo ""
    echo "Or run: minikube service $FRONTEND_RELEASE-svc -n $NAMESPACE"
fi
