#!/bin/bash
set -e

# ECR push script executed by CodeBuild
# Authenticates with ECR and pushes Docker image

AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-123456789012}
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
REPOSITORY_NAME=${REPOSITORY_NAME:-lekka-service}
IMAGE_TAG=${IMAGE_TAG:-latest}

IMAGE_REPO_NAME="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$REPOSITORY_NAME"

echo "=========================================="
echo "Pushing Image to ECR"
echo "=========================================="

echo "Authenticating with ECR..."
aws ecr get-login-password --region "$AWS_DEFAULT_REGION" | \
  docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"

echo "Pushing image with tag: $IMAGE_TAG"
docker push "$IMAGE_REPO_NAME:$IMAGE_TAG"

echo "Pushing image with tag: latest"
docker push "$IMAGE_REPO_NAME:latest"

echo "Image pushed successfully to ECR!"

