#!/bin/bash
set -e

# Helm deployment script for CodePipeline
# Deploys application to EKS using Helm

RELEASE_NAME=${RELEASE_NAME:-lekka-service}
NAMESPACE=${NAMESPACE:-lekka-service}
CHART_PATH=${CHART_PATH:-./helm}
VALUES_FILE=${VALUES_FILE:-./helm/values.yaml}

echo "=========================================="
echo "Deploying to EKS with Helm"
echo "=========================================="
echo "Release: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo "Chart: $CHART_PATH"

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Check if release exists
if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
  echo "Upgrading existing Helm release: $RELEASE_NAME"
  helm upgrade "$RELEASE_NAME" "$CHART_PATH" \
    --namespace "$NAMESPACE" \
    --values "$VALUES_FILE" \
    --wait \
    --timeout 5m
else
  echo "Installing new Helm release: $RELEASE_NAME"
  helm install "$RELEASE_NAME" "$CHART_PATH" \
    --namespace "$NAMESPACE" \
    --values "$VALUES_FILE" \
    --wait \
    --timeout 5m
fi

echo "Deployment completed successfully!"
echo "Checking deployment status..."
kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=5m

echo "Helm deployment finished!"

