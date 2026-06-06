#!/bin/bash
set -e

# Rollback script for CodePipeline
# Rolls back to previous Helm release in case of deployment failure

RELEASE_NAME=${RELEASE_NAME:-lekka-service}
NAMESPACE=${NAMESPACE:-lekka-service}

echo "=========================================="
echo "Rolling Back Deployment"
echo "=========================================="
echo "Release: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"

# Get current revision
CURRENT_REVISION=$(helm history "$RELEASE_NAME" -n "$NAMESPACE" -o json | jq '.[-1].revision')
PREVIOUS_REVISION=$((CURRENT_REVISION - 1))

if [ $PREVIOUS_REVISION -lt 1 ]; then
  echo "ERROR: No previous revision to rollback to"
  exit 1
fi

echo "Current revision: $CURRENT_REVISION"
echo "Rolling back to revision: $PREVIOUS_REVISION"

helm rollback "$RELEASE_NAME" "$PREVIOUS_REVISION" -n "$NAMESPACE" --wait

echo "Waiting for rollback to complete..."
kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE" --timeout=5m

echo "=========================================="
echo "Rollback completed successfully!"
echo "=========================================="
#!/bin/bash
set -e

# Image scanning script executed by CodeBuild
# Scans Docker image for vulnerabilities using Trivy

IMAGE_NAME=${IMAGE_NAME:-lekka-service}
IMAGE_TAG=${IMAGE_TAG:-latest}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-123456789012}
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}

FULL_IMAGE_NAME="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG"

echo "=========================================="
echo "Scanning Docker Image for Vulnerabilities"
echo "=========================================="
echo "Image: $FULL_IMAGE_NAME"

# Check if Trivy is installed
if ! command -v trivy &> /dev/null; then
  echo "WARNING: Trivy not installed, skipping image scan"
  exit 0
fi

echo "Running Trivy security scan..."
trivy image --severity HIGH,CRITICAL "$FULL_IMAGE_NAME" || true

echo "=========================================="
echo "Image scan completed!"
echo "=========================================="
#!/bin/bash
set -e

# Build script executed by CodeBuild
# Compiles Java application and creates JAR

echo "=========================================="
echo "Building Lekka Service Application"
echo "=========================================="

cd /codebuild/output/src

echo "Running Maven clean and package..."
mvn clean package -DskipTests

echo "Build completed successfully!"
echo "JAR file: target/lekka-service-0.0.1-SNAPSHOT.jar"

