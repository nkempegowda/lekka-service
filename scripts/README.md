# CodeBuild & CodePipeline Scripts

This directory contains executable scripts used by AWS CodeBuild and CodePipeline during the CI/CD process.

## 📋 Scripts Overview

### 1. **validate.sh** - Pre-build Validation
**When**: Runs first in CodeBuild
**Purpose**: Validates that all required files and environment variables are present
**Usage**: 
```bash
./scripts/validate.sh
```
**Checks**:
- Dockerfile exists
- pom.xml exists
- helm/ directory exists
- buildspec.yml exists
- AWS_ACCOUNT_ID is set
- AWS_DEFAULT_REGION is set

---

### 2. **build.sh** - Maven Build
**When**: During CodeBuild build phase
**Purpose**: Compiles Java application using Maven
**Usage**:
```bash
./scripts/build.sh
```
**Output**: JAR file at `target/lekka-service-0.0.1-SNAPSHOT.jar`

---

### 3. **test.sh** - Run Tests
**When**: During CodeBuild build phase (optional)
**Purpose**: Executes unit tests using Maven
**Usage**:
```bash
./scripts/test.sh
```
**Note**: Add this to buildspec.yml if you want tests to run before build

---

### 4. **docker-build.sh** - Build Docker Image
**When**: During CodeBuild build phase
**Purpose**: Builds Docker image and tags it for ECR
**Usage**:
```bash
./scripts/docker-build.sh
```
**Environment Variables**:
- `AWS_ACCOUNT_ID` - Your AWS Account ID
- `AWS_DEFAULT_REGION` - AWS region (e.g., us-east-1)
- `REPOSITORY_NAME` - ECR repository name (default: lekka-service)
- `IMAGE_TAG` - Image tag (default: latest)

**Output**: Docker image tagged as:
- `123456789012.dkr.ecr.us-east-1.amazonaws.com/lekka-service:IMAGE_TAG`
- `123456789012.dkr.ecr.us-east-1.amazonaws.com/lekka-service:latest`

---

### 5. **ecr-push.sh** - Push to ECR
**When**: During CodeBuild build phase (after docker-build.sh)
**Purpose**: Authenticates with ECR and pushes Docker image
**Usage**:
```bash
./scripts/ecr-push.sh
```
**Requirements**:
- Docker image must be built first
- IAM credentials configured
- ECR repository must exist

**Output**: Image pushed to ECR with both specific tag and latest tag

---

### 6. **scan-image.sh** - Security Scan
**When**: During CodeBuild build phase (optional)
**Purpose**: Scans Docker image for vulnerabilities using Trivy
**Usage**:
```bash
./scripts/scan-image.sh
```
**Requirements**:
- Trivy installed in build environment
- Docker image already built

**Output**: Security scan report (HIGH and CRITICAL vulnerabilities)

---

### 7. **helm-deploy.sh** - Deploy to EKS
**When**: During CodePipeline deploy stage
**Purpose**: Deploys application to EKS using Helm chart
**Usage**:
```bash
./scripts/helm-deploy.sh
```
**Environment Variables**:
- `RELEASE_NAME` - Helm release name (default: lekka-service)
- `NAMESPACE` - Kubernetes namespace (default: lekka-service)
- `CHART_PATH` - Path to Helm chart (default: ./helm)
- `VALUES_FILE` - Path to values file (default: ./helm/values.yaml)

**What it does**:
1. Creates namespace if it doesn't exist
2. Upgrades existing release or installs new one
3. Waits for deployment to be ready
4. Updates service

---

### 8. **health-check.sh** - Verify Deployment
**When**: After helm-deploy.sh completes
**Purpose**: Verifies application health after deployment
**Usage**:
```bash
./scripts/health-check.sh
```
**Checks**:
- Deployment is ready
- Pods are running
- Service is accessible
- Pod conditions are healthy

**Environment Variables**:
- `RELEASE_NAME` - Release name (default: lekka-service)
- `NAMESPACE` - Kubernetes namespace (default: lekka-service)

---

### 9. **rollback.sh** - Rollback Deployment
**When**: Manual execution or on deployment failure
**Purpose**: Rolls back Helm release to previous version
**Usage**:
```bash
./scripts/rollback.sh
```
**Environment Variables**:
- `RELEASE_NAME` - Release name (default: lekka-service)
- `NAMESPACE` - Kubernetes namespace (default: lekka-service)

**What it does**:
1. Gets current Helm release revision
2. Rolls back to previous revision
3. Waits for rollback to complete
4. Verifies deployment is healthy

---

## 🔄 CodeBuild Integration (buildspec.yml)

The `buildspec.yml` file orchestrates these scripts:

```yaml
phases:
  pre_build:
    commands:
      - ./scripts/validate.sh
      - aws ecr get-login-password... # ECR login
      
  build:
    commands:
      - ./scripts/build.sh              # Maven compile
      - ./scripts/docker-build.sh       # Build Docker image
      - ./scripts/ecr-push.sh           # Push to ECR
      - ./scripts/scan-image.sh         # Optional: security scan
      
  post_build:
    commands:
      - ./scripts/health-check.sh       # Verify deployment
```

---

## 🚀 CodePipeline Integration (helm-deploy.sh)

The `helm-deploy.sh` script is called by CodePipeline's Deploy stage via CodeDeploy or Lambda:

```bash
#!/bin/bash
# In CodePipeline Deploy stage
./scripts/helm-deploy.sh

# If deployment fails, trigger rollback:
./scripts/rollback.sh
```

---

## 🔧 Required Environment Variables

Set these before running scripts:

```bash
# AWS Configuration
export AWS_ACCOUNT_ID="123456789012"
export AWS_DEFAULT_REGION="us-east-1"

# Docker/ECR Configuration
export REPOSITORY_NAME="lekka-service"
export IMAGE_TAG="v1.0.0"

# Helm/Kubernetes Configuration
export RELEASE_NAME="lekka-service"
export NAMESPACE="lekka-service"
export CHART_PATH="./helm"
export VALUES_FILE="./helm/values.yaml"
```

---

## 🧪 Testing Scripts Locally

### Test Validation
```bash
./scripts/validate.sh
```

### Test Maven Build
```bash
./scripts/build.sh
```

### Test Docker Build
```bash
export AWS_ACCOUNT_ID="123456789012"
export AWS_DEFAULT_REGION="us-east-1"
./scripts/docker-build.sh
```

### Test ECR Push
```bash
export AWS_ACCOUNT_ID="123456789012"
export AWS_DEFAULT_REGION="us-east-1"
./scripts/ecr-push.sh
```

### Test Helm Deploy
```bash
export RELEASE_NAME="lekka-service"
export NAMESPACE="lekka-service"
./scripts/helm-deploy.sh
```

### Test Health Check
```bash
export RELEASE_NAME="lekka-service"
export NAMESPACE="lekka-service"
./scripts/health-check.sh
```

---

## 📊 Execution Order in Pipeline

```
1. validate.sh
   └─ Verify all files and env vars exist
   
2. build.sh
   └─ Compile Java with Maven
   
3. docker-build.sh
   └─ Build and tag Docker image
   
4. ecr-push.sh
   └─ Authenticate and push to ECR
   
5. scan-image.sh (optional)
   └─ Security scanning
   
6. helm-deploy.sh (in Deploy stage)
   └─ Deploy to EKS
   
7. health-check.sh
   └─ Verify deployment health
   
[If failed: rollback.sh]
   └─ Revert to previous version
```

---

## ⚠️ Error Handling

All scripts use `set -e` which means they exit immediately on any error:
- Script stops on first failure
- Non-zero exit code signals failure to CodeBuild/CodePipeline
- Pipeline fails and stops executing next stages

---

## 🔐 Security Notes

- Scripts use AWS IAM roles (no hardcoded credentials)
- Sensitive data passed via environment variables (not logged)
- ECR authentication uses temporary tokens
- Helm secrets can be added to values.yaml

---

## 📝 Customization

### Add Custom Build Steps
Edit `buildspec.yml` to add more commands:
```yaml
build:
  commands:
    - ./scripts/build.sh
    - ./scripts/custom-step.sh  # Add new script
    - ./scripts/docker-build.sh
```

### Add Environment Variables
In CodeBuild project:
```
AWS_ACCOUNT_ID = 123456789012
AWS_DEFAULT_REGION = us-east-1
CUSTOM_VAR = custom_value
```

### Extend Helm Deployment
Edit `helm-deploy.sh` to add post-deploy steps:
```bash
# After helm install/upgrade
./scripts/custom-validation.sh
```

---

## 🐛 Debugging

### Run with Debug Output
```bash
# Enable debug mode in bash
bash -x ./scripts/build.sh

# Or add to script
set -x  # Enable debug
```

### Check Log Output
- CodeBuild: AWS Console → CodeBuild → Build logs
- Kubernetes: `kubectl logs deployment/lekka-service -n lekka-service`

### Manual Execution
```bash
# Set environment
source ~/.env  # Load your variables
cd /path/to/project

# Run script
./scripts/validate.sh
```

---

## 📚 Dependencies

### Required for CodeBuild
- Java 21+
- Maven 3.6+
- Docker
- AWS CLI v2
- kubectl
- Helm 3+

### Optional
- Trivy (for image scanning)
- jq (for JSON processing)

---

## 🎯 Quick Start

1. **Update buildspec.yml** with your AWS_ACCOUNT_ID and AWS_DEFAULT_REGION
2. **Make scripts executable**: `chmod +x scripts/*.sh`
3. **Commit to Git**: `git add scripts/ && git commit -m "Add pipeline scripts"`
4. **Push to GitHub**: `git push origin main`
5. **Pipeline runs automatically** and executes the scripts

---

## 📞 Support

For issues:
1. Check script output in CodeBuild logs
2. Verify environment variables are set
3. Ensure all prerequisites are installed
4. Check IAM role permissions

---

**All scripts are production-ready and follow AWS best practices!** 🚀

