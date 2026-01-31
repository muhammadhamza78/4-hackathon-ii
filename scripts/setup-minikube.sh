#!/bin/bash
# ==============================================================================
# Phase IV - Minikube Setup Script (Bash)
# ==============================================================================

set -e

# Default values
MEMORY=4096
CPUS=4
DRIVER="docker"
K8S_VERSION="v1.28.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --memory) MEMORY="$2"; shift 2 ;;
        --cpus) CPUS="$2"; shift 2 ;;
        --driver) DRIVER="$2"; shift 2 ;;
        --k8s-version) K8S_VERSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "  --memory MB          Memory allocation (default: 4096)"
            echo "  --cpus N             CPU cores (default: 4)"
            echo "  --driver DRIVER      Minikube driver (default: docker)"
            echo "  --k8s-version VER    Kubernetes version (default: v1.28.0)"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Phase IV - Minikube Setup${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

# Check Docker
echo -e "${YELLOW}[1/6] Checking Docker...${NC}"
if ! docker info &>/dev/null; then
    echo -e "${RED}  ERROR: Docker is not running${NC}"
    echo -e "${YELLOW}  Please start Docker first${NC}"
    exit 1
fi
echo -e "${GREEN}  Docker is running${NC}"

# Check Minikube
echo -e "${YELLOW}[2/6] Checking Minikube installation...${NC}"
if ! command -v minikube &>/dev/null; then
    echo -e "${RED}  ERROR: Minikube is not installed${NC}"
    echo -e "${YELLOW}  Install from: https://minikube.sigs.k8s.io/docs/start/${NC}"
    exit 1
fi
echo -e "${GREEN}  Minikube version: $(minikube version --short)${NC}"

# Check kubectl
echo -e "${YELLOW}[3/6] Checking kubectl installation...${NC}"
if ! command -v kubectl &>/dev/null; then
    echo -e "${RED}  ERROR: kubectl is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}  kubectl is installed${NC}"

# Check Helm
echo -e "${YELLOW}[4/6] Checking Helm installation...${NC}"
if ! command -v helm &>/dev/null; then
    echo -e "${RED}  ERROR: Helm is not installed${NC}"
    echo -e "${YELLOW}  Install from: https://helm.sh/docs/intro/install/${NC}"
    exit 1
fi
echo -e "${GREEN}  Helm version: $(helm version --short)${NC}"

# Check Minikube status
echo -e "${YELLOW}[5/6] Checking Minikube status...${NC}"
MINIKUBE_STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")

if [ "$MINIKUBE_STATUS" = "Running" ]; then
    echo -e "${GREEN}  Minikube is already running${NC}"
    read -p "  Do you want to restart Minikube? (y/N) " restart
    if [ "$restart" = "y" ] || [ "$restart" = "Y" ]; then
        echo "  Stopping Minikube..."
        minikube stop
        echo "  Starting Minikube with new configuration..."
        minikube start --driver=$DRIVER --memory=$MEMORY --cpus=$CPUS --kubernetes-version=$K8S_VERSION
    fi
else
    echo "  Starting Minikube..."
    minikube start --driver=$DRIVER --memory=$MEMORY --cpus=$CPUS --kubernetes-version=$K8S_VERSION
    echo -e "${GREEN}  Minikube started successfully${NC}"
fi

# Configure kubectl
echo -e "${YELLOW}[6/6] Configuring kubectl context...${NC}"
kubectl config use-context minikube
echo -e "${GREEN}  kubectl context set to minikube${NC}"

# Display info
echo ""
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Minikube Setup Complete!${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""
echo -e "${YELLOW}Cluster Information:${NC}"
echo "  Minikube IP: $(minikube ip)"
echo "  Kubernetes Version: $K8S_VERSION"
echo "  Memory: ${MEMORY}MB"
echo "  CPUs: $CPUS"
echo "  Driver: $DRIVER"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Run ./build-images.sh to build Docker images"
echo "  2. Run ./deploy.sh to deploy the application"
echo ""
echo -e "${YELLOW}To use Minikube's Docker daemon:${NC}"
echo '  eval $(minikube docker-env)'
echo ""
