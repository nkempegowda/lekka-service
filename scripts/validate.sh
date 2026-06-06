#!/bin/bash
set -e

# Validation script executed by CodeBuild
# Validates configuration and prerequisites

echo "=========================================="
echo "Validating Build Configuration"
echo "=========================================="

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
  echo "ERROR: Dockerfile not found in project root"
  exit 1
fi
echo "✓ Dockerfile found"

# Check if pom.xml exists
if [ ! -f "pom.xml" ]; then
  echo "ERROR: pom.xml not found in project root"
  exit 1
fi
echo "✓ pom.xml found"

# Check if helm chart exists
if [ ! -d "helm" ]; then
  echo "ERROR: helm directory not found"
  exit 1
fi
echo "✓ Helm chart directory found"

# Check if buildspec.yml exists
if [ ! -f "buildspec.yml" ]; then
  echo "ERROR: buildspec.yml not found"
  exit 1
fi
echo "✓ buildspec.yml found"

# Validate environment variables
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "ERROR: AWS_ACCOUNT_ID not set"
  exit 1
fi
echo "✓ AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"

if [ -z "$AWS_DEFAULT_REGION" ]; then
  echo "ERROR: AWS_DEFAULT_REGION not set"
  exit 1
fi
echo "✓ AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"

echo "=========================================="
echo "All validations passed!"
echo "=========================================="

