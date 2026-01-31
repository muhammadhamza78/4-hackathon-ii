#!/bin/bash
# ==============================================================================
# Phase IV - Docker Image Build Script (Bash)
# ==============================================================================

set -e

# Default values
BACKEND_TAG="latest"
FRONTEND_TAG="latest"
USE_MINIKUBE_DOCKER=true
BACKEND_ONLY=false
FRONTEND_ONLY=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backend-tag) BACKEND_TAG="$2"; shift 2 ;;
        --frontend-tag) FRONTEND_TAG="$2"; shift 2 ;;
        --local-docker) USE_MINIKUBE_DOCKER=false; shift ;;
        --backend-only) BACKEND_ONLY=true; shift ;;
        --frontend-only) FRONTEND_ONLY=true; shift ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "  --backend-tag TAG    Backend image tag (default: latest)"
            echo "  --frontend-tag TAG   Frontend image tag (default: latest)"
            echo "  --local-docker       Use local Docker instead of Minikube's"
            echo "  --backend-only       Only build backend image"
            echo "  --frontend-only      Only build frontend image"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Phase IV - Docker Image Build${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

# Check Docker
echo -e "${YELLOW}[1/5] Checking Docker...${NC}"
if ! docker info &>/dev/null; then
    echo -e "${RED}  ERROR: Docker is not running${NC}"
    exit 1
fi
echo -e "${GREEN}  Docker is running${NC}"

# Configure Minikube Docker
echo -e "${YELLOW}[2/5] Configuring Docker environment...${NC}"
if [ "$USE_MINIKUBE_DOCKER" = true ]; then
    if minikube status --format='{{.Host}}' 2>/dev/null | grep -q "Running"; then
        eval $(minikube docker-env)
        echo -e "${GREEN}  Using Minikube's Docker daemon${NC}"
    else
        echo -e "${YELLOW}  WARNING: Minikube not running, using local Docker${NC}"
    fi
else
    echo -e "${GREEN}  Using local Docker daemon${NC}"
fi

# Build Backend
if [ "$FRONTEND_ONLY" = false ]; then
    echo -e "${YELLOW}[3/5] Building Backend Image...${NC}"
    echo -e "${GRAY}  Context: $PROJECT_ROOT/backend${NC}"
    echo -e "${GRAY}  Dockerfile: $PROJECT_ROOT/docker/backend/Dockerfile${NC}"
    echo -e "${GRAY}  Tag: todo-backend:$BACKEND_TAG${NC}"

    docker build \
        -f "$PROJECT_ROOT/docker/backend/Dockerfile" \
        -t "todo-backend:$BACKEND_TAG" \
        "$PROJECT_ROOT/backend"

    echo -e "${GREEN}  Backend image built successfully${NC}"
else
    echo -e "${YELLOW}[3/5] Skipping Backend Image...${NC}"
fi

# Build Frontend
if [ "$BACKEND_ONLY" = false ]; then
    echo -e "${YELLOW}[4/5] Building Frontend Image...${NC}"
    echo -e "${GRAY}  Context: $PROJECT_ROOT/frontend${NC}"
    echo -e "${GRAY}  Dockerfile: $PROJECT_ROOT/docker/frontend/Dockerfile${NC}"
    echo -e "${GRAY}  Tag: todo-frontend:$FRONTEND_TAG${NC}"

    docker build \
        -f "$PROJECT_ROOT/docker/frontend/Dockerfile" \
        -t "todo-frontend:$FRONTEND_TAG" \
        --build-arg NEXT_PUBLIC_API_URL=http://todo-backend-svc:8000 \
        "$PROJECT_ROOT/frontend"

    echo -e "${GREEN}  Frontend image built successfully${NC}"
else
    echo -e "${YELLOW}[4/5] Skipping Frontend Image...${NC}"
fi

# Verify
echo -e "${YELLOW}[5/5] Verifying built images...${NC}"
echo ""
docker images | grep -E "todo-backend|todo-frontend|REPOSITORY"
echo ""

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Image Build Complete!${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  Run ./deploy.sh to deploy the application to Minikube"
echo ""
