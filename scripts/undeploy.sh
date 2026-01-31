#!/bin/bash
# ==============================================================================
# Phase IV - Kubernetes Undeploy Script (Bash)
# ==============================================================================

set -e

# Default values
NAMESPACE="${NAMESPACE:-todo-chatbot}"
BACKEND_RELEASE="${BACKEND_RELEASE:-todo-backend}"
FRONTEND_RELEASE="${FRONTEND_RELEASE:-todo-frontend}"
DELETE_NAMESPACE=false
FORCE=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --backend-release)
            BACKEND_RELEASE="$2"
            shift 2
            ;;
        --frontend-release)
            FRONTEND_RELEASE="$2"
            shift 2
            ;;
        --delete-namespace)
            DELETE_NAMESPACE=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -n, --namespace NAME        Kubernetes namespace (default: todo-chatbot)"
            echo "      --backend-release NAME  Backend Helm release name (default: todo-backend)"
            echo "      --frontend-release NAME Frontend Helm release name (default: todo-frontend)"
            echo "      --delete-namespace      Also delete the namespace"
            echo "  -f, --force                 Skip confirmation prompt"
            echo "  -h, --help                  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Phase IV - Kubernetes Undeploy${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

# Confirm deletion
if [ "$FORCE" = false ]; then
    echo -e "${YELLOW}This will delete the following resources:${NC}"
    echo -e "${WHITE}  - Helm release: $BACKEND_RELEASE${NC}"
    echo -e "${WHITE}  - Helm release: $FRONTEND_RELEASE${NC}"
    if [ "$DELETE_NAMESPACE" = true ]; then
        echo -e "${RED}  - Namespace: $NAMESPACE (and ALL resources within)${NC}"
    fi
    echo ""
    read -p "Are you sure you want to continue? (y/N) " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        exit 0
    fi
fi

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo -e "${YELLOW}Namespace '$NAMESPACE' does not exist. Nothing to delete.${NC}"
    exit 0
fi

# Uninstall Frontend
echo -e "${YELLOW}[1/3] Uninstalling Frontend...${NC}"
if helm list -n "$NAMESPACE" | grep -q "$FRONTEND_RELEASE"; then
    helm uninstall "$FRONTEND_RELEASE" -n "$NAMESPACE"
    echo -e "${GREEN}  Frontend uninstalled${NC}"
else
    echo -e "${GRAY}  Frontend release not found, skipping${NC}"
fi

# Uninstall Backend
echo -e "${YELLOW}[2/3] Uninstalling Backend...${NC}"
if helm list -n "$NAMESPACE" | grep -q "$BACKEND_RELEASE"; then
    helm uninstall "$BACKEND_RELEASE" -n "$NAMESPACE"
    echo -e "${GREEN}  Backend uninstalled${NC}"
else
    echo -e "${GRAY}  Backend release not found, skipping${NC}"
fi

# Delete namespace if requested
if [ "$DELETE_NAMESPACE" = true ]; then
    echo -e "${YELLOW}[3/3] Deleting namespace...${NC}"
    kubectl delete namespace "$NAMESPACE"
    echo -e "${GREEN}  Namespace deleted${NC}"
else
    echo -e "${YELLOW}[3/3] Keeping namespace '$NAMESPACE'${NC}"
    echo -e "${GRAY}  To delete namespace, run with --delete-namespace flag${NC}"
fi

echo ""
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Undeploy Complete!${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

# Show remaining resources
if [ "$DELETE_NAMESPACE" = false ]; then
    echo -e "${YELLOW}Remaining resources in namespace '$NAMESPACE':${NC}"
    kubectl get all -n "$NAMESPACE" 2>/dev/null || true
fi
