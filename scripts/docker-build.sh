#!/bin/bash
set -e

# Docker build script executed by CodeBuild
# Builds and tags Docker image

AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-123456789012}
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
REPOSITORY_NAME=${REPOSITORY_NAME:-lekka-service}
IMAGE_TAG=${IMAGE_TAG:-latest}

IMAGE_REPO_NAME="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$REPOSITORY_NAME"

echo "=========================================="
echo "Building Docker Image"
echo "=========================================="
echo "Repository: $IMAGE_REPO_NAME"
echo "Tag: $IMAGE_TAG"

docker build -t "$IMAGE_REPO_NAME:$IMAGE_TAG" .
docker tag "$IMAGE_REPO_NAME:$IMAGE_TAG" "$IMAGE_REPO_NAME:latest"

echo "Docker image built successfully!"
echo "Image: $IMAGE_REPO_NAME:$IMAGE_TAG"

