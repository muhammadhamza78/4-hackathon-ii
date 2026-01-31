#!/bin/bash
# ==============================================================================
# Phase IV - Deployment Validation Script (Bash)
# ==============================================================================

# Default values
NAMESPACE="${NAMESPACE:-todo-chatbot}"
BACKEND_RELEASE="${BACKEND_RELEASE:-todo-backend}"
FRONTEND_RELEASE="${FRONTEND_RELEASE:-todo-frontend}"
VERBOSE=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

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
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -n, --namespace NAME        Kubernetes namespace (default: todo-chatbot)"
            echo "      --backend-release NAME  Backend Helm release name (default: todo-backend)"
            echo "      --frontend-release NAME Frontend Helm release name (default: todo-frontend)"
            echo "  -v, --verbose               Show detailed error messages"
            echo "  -h, --help                  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Test function
test_check() {
    local name="$1"
    local test_cmd="$2"

    ((TOTAL_TESTS++))
    printf "  Testing: %s... " "$name"

    if eval "$test_cmd" &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED_TESTS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED_TESTS++))
        if [ "$VERBOSE" = true ]; then
            echo -e "${RED}    Command: $test_cmd${NC}"
        fi
        return 1
    fi
}

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Phase IV - Deployment Validation${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""

# 1. Infrastructure Checks
echo -e "${YELLOW}[1/5] Infrastructure Checks${NC}"

test_check "Minikube is running" \
    '[ "$(minikube status --format="{{.Host}}" 2>/dev/null)" = "Running" ]'

test_check "kubectl can connect to cluster" \
    'kubectl cluster-info &>/dev/null'

test_check "Namespace exists" \
    '[ "$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)" = "namespace/$NAMESPACE" ]'

# 2. Pod Status Checks
echo ""
echo -e "${YELLOW}[2/5] Pod Status Checks${NC}"

test_check "Backend pods are running" \
    'kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/name=todo-backend" -o jsonpath="{.items[*].status.phase}" 2>/dev/null | grep -q "Running"'

test_check "Frontend pods are running" \
    'kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/name=todo-frontend" -o jsonpath="{.items[*].status.phase}" 2>/dev/null | grep -q "Running"'

test_check "All pods are ready" \
    '[ -z "$(kubectl get pods -n $NAMESPACE -o jsonpath="{.items[?(@.status.containerStatuses[0].ready==false)].metadata.name}" 2>/dev/null)" ]'

# 3. Service Checks
echo ""
echo -e "${YELLOW}[3/5] Service Checks${NC}"

test_check "Backend service exists" \
    '[ "$(kubectl get svc ${BACKEND_RELEASE}-svc -n $NAMESPACE -o name 2>/dev/null)" = "service/${BACKEND_RELEASE}-svc" ]'

test_check "Frontend service exists" \
    '[ "$(kubectl get svc ${FRONTEND_RELEASE}-svc -n $NAMESPACE -o name 2>/dev/null)" = "service/${FRONTEND_RELEASE}-svc" ]'

test_check "Frontend NodePort is configured" \
    '[ "$(kubectl get svc ${FRONTEND_RELEASE}-svc -n $NAMESPACE -o jsonpath="{.spec.ports[0].nodePort}" 2>/dev/null)" = "30080" ]'

# 4. Health Endpoint Checks
echo ""
echo -e "${YELLOW}[4/5] Health Endpoint Checks${NC}"

BACKEND_POD=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/name=todo-backend" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

test_check "Backend health endpoint responds" \
    '[ -n "$BACKEND_POD" ] && [ "$(kubectl exec $BACKEND_POD -n $NAMESPACE -- curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null)" = "200" ]'

test_check "Backend API docs accessible" \
    '[ -n "$BACKEND_POD" ] && [ "$(kubectl exec $BACKEND_POD -n $NAMESPACE -- curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/docs 2>/dev/null)" = "200" ]'

FRONTEND_POD=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/name=todo-frontend" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

test_check "Frontend responds" \
    '[ -n "$FRONTEND_POD" ] && kubectl exec $FRONTEND_POD -n $NAMESPACE -- wget -q -O /dev/null --spider http://localhost:3000/ 2>/dev/null'

# 5. Configuration Checks
echo ""
echo -e "${YELLOW}[5/5] Configuration Checks${NC}"

test_check "Backend ConfigMap exists" \
    '[ "$(kubectl get configmap ${BACKEND_RELEASE}-config -n $NAMESPACE -o name 2>/dev/null)" = "configmap/${BACKEND_RELEASE}-config" ]'

test_check "Backend Secrets exist" \
    '[ "$(kubectl get secret ${BACKEND_RELEASE}-secrets -n $NAMESPACE -o name 2>/dev/null)" = "secret/${BACKEND_RELEASE}-secrets" ]'

test_check "Frontend ConfigMap exists" \
    '[ "$(kubectl get configmap ${FRONTEND_RELEASE}-config -n $NAMESPACE -o name 2>/dev/null)" = "configmap/${FRONTEND_RELEASE}-config" ]'

# Summary
echo ""
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}  Validation Summary${NC}"
echo -e "${CYAN}=============================================${NC}"
echo ""
echo "  Total Tests: $TOTAL_TESTS"
echo -e "  ${GREEN}Passed: $PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "  ${RED}Failed: $FAILED_TESTS${NC}"
else
    echo -e "  ${GREEN}Failed: $FAILED_TESTS${NC}"
fi
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    echo ""

    # Show access information
    MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "unknown")
    echo -e "${YELLOW}Access the application:${NC}"
    echo -e "${WHITE}  Frontend URL: http://${MINIKUBE_IP}:30080${NC}"
    echo -e "${WHITE}  Backend API:  http://${MINIKUBE_IP}:30080/api (via frontend proxy)${NC}"
    echo ""
    echo -e "Or run: minikube service ${FRONTEND_RELEASE}-svc -n $NAMESPACE"

    exit 0
else
    echo -e "${RED}Some validations failed. Check the output above for details.${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting commands:${NC}"
    echo "  kubectl get pods -n $NAMESPACE"
    echo "  kubectl describe pods -n $NAMESPACE"
    echo "  kubectl logs -l app.kubernetes.io/name=todo-backend -n $NAMESPACE"
    echo "  kubectl logs -l app.kubernetes.io/name=todo-frontend -n $NAMESPACE"

    exit 1
fi
