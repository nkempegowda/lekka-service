#!/bin/bash
set -e

# Health check script executed by CodePipeline
# Verifies application health after deployment

RELEASE_NAME=${RELEASE_NAME:-lekka-service}
NAMESPACE=${NAMESPACE:-lekka-service}
MAX_RETRIES=${MAX_RETRIES:-30}
RETRY_DELAY=${RETRY_DELAY:-10}

echo "=========================================="
echo "Performing Health Checks"
echo "=========================================="
echo "Release: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=5m

# Get service details
echo "Getting service information..."
SERVICE_IP=$(kubectl get svc "$RELEASE_NAME" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")

if [ "$SERVICE_IP" != "pending" ]; then
  echo "Service IP/Hostname: $SERVICE_IP"
else
  echo "Service IP/Hostname: Pending (ClusterIP service)"
fi

# Check pod status
echo "Checking pod status..."
kubectl get pods -n "$NAMESPACE" -l app="$RELEASE_NAME"

# Get pod details
PODS=$(kubectl get pods -n "$NAMESPACE" -l app="$RELEASE_NAME" -o jsonpath='{.items[*].metadata.name}')

if [ -z "$PODS" ]; then
  echo "ERROR: No pods found"
  exit 1
fi

# Check each pod
for pod in $PODS; do
  echo "Checking pod: $pod"
  kubectl describe pod "$pod" -n "$NAMESPACE" | grep -A 5 "Conditions:"
done

echo "=========================================="
echo "Health checks completed!"
echo "=========================================="

