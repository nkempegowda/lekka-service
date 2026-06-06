# CodeBuild & CodePipeline Scripts - Usage Summary

## 📁 Project Structure

```
lekka-service-final/
├── buildspec.yml              ← CodeBuild configuration
├── Dockerfile                 ← Docker image definition
├── pom.xml                    ← Maven configuration
├── helm/                      ← Kubernetes Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── scripts/                   ← CI/CD executable scripts
    ├── validate.sh            ← Pre-build validation
    ├── build.sh               ← Maven compilation
    ├── test.sh                ← Unit tests
    ├── docker-build.sh        ← Docker image build
    ├── ecr-push.sh            ← Push to ECR registry
    ├── scan-image.sh          ← Security scanning
    ├── helm-deploy.sh         ← Deploy to EKS
    ├── health-check.sh        ← Verify deployment
    ├── rollback.sh            ← Rollback deployment
    └── README.md              ← Scripts documentation
```

## 🎯 What You Have

### Core Build Script
- **buildspec.yml** - Orchestrates all scripts during CodeBuild execution

### Executable Scripts (in scripts/ directory)
1. **validate.sh** - Checks prerequisites
2. **build.sh** - Maven build
3. **test.sh** - Run tests
4. **docker-build.sh** - Build Docker image
5. **ecr-push.sh** - Push to ECR
6. **scan-image.sh** - Security scan
7. **helm-deploy.sh** - Deploy to EKS
8. **health-check.sh** - Verify deployment
9. **rollback.sh** - Rollback if needed

## 🚀 How CodeBuild Uses These Scripts

```
buildspec.yml (orchestrator)
    ↓
Phase: pre_build
    └─ validate.sh              ✓ Check files exist
    
Phase: build
    ├─ build.sh                 ✓ Maven compile
    ├─ docker-build.sh          ✓ Build Docker image
    └─ ecr-push.sh              ✓ Push to ECR
    
Phase: post_build
    └─ health-check.sh          ✓ Verify deployment
```

## 🔧 Setup Instructions

### 1. Update buildspec.yml
```bash
# Edit buildspec.yml and update:
env:
  variables:
    AWS_ACCOUNT_ID: "YOUR_ACCOUNT_ID"        # e.g., 123456789012
    AWS_DEFAULT_REGION: "YOUR_REGION"        # e.g., us-east-1
```

### 2. Update helm/values.yaml
```bash
# Edit helm/values.yaml and update:
image:
  repository: "YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/lekka-service"
```

### 3. Commit Changes
```bash
git add buildspec.yml helm/ scripts/
git commit -m "Add CodeBuild and CodePipeline scripts"
git push origin main
```

## 📋 Scripts Description

| Script | Purpose | Executed By |
|--------|---------|-------------|
| validate.sh | Check all required files | CodeBuild |
| build.sh | Maven compilation | CodeBuild |
| test.sh | Run unit tests | CodeBuild (optional) |
| docker-build.sh | Build Docker image | CodeBuild |
| ecr-push.sh | Push image to ECR | CodeBuild |
| scan-image.sh | Security scan | CodeBuild (optional) |
| helm-deploy.sh | Deploy to EKS | CodePipeline Deploy stage |
| health-check.sh | Verify deployment | CodePipeline |
| rollback.sh | Rollback on failure | CodePipeline (manual) |

## 🔄 Pipeline Flow

```
GITHUB PUSH
    ↓
CodePipeline detects change
    ↓
Stage 1: SOURCE
    └─ Pull code from GitHub
    
Stage 2: BUILD (runs CodeBuild)
    ├─ buildspec.yml starts
    ├─ validate.sh
    ├─ build.sh
    ├─ docker-build.sh
    ├─ ecr-push.sh
    └─ health-check.sh
    
Stage 3: DEPLOY (uses artifacts)
    └─ helm-deploy.sh
    
Application running on EKS ✓
```

## 🎯 Key Environment Variables

These are automatically set by CodeBuild:

| Variable | Value | Set By |
|----------|-------|--------|
| AWS_ACCOUNT_ID | Your AWS Account ID | buildspec.yml |
| AWS_DEFAULT_REGION | us-east-1 (or your region) | buildspec.yml |
| CODEBUILD_RESOLVED_SOURCE_VERSION | Git commit SHA | CodeBuild |
| REPOSITORY_NAME | lekka-service | buildspec.yml |

## 🧪 Test Scripts Locally

```bash
# Navigate to project
cd /home/dell/sriganesha/lekka-service-final

# Make scripts executable (if not already)
chmod +x scripts/*.sh

# Test validation
./scripts/validate.sh

# Test Maven build
./scripts/build.sh

# Test Docker build (requires Docker running)
export AWS_ACCOUNT_ID="123456789012"
export AWS_DEFAULT_REGION="us-east-1"
./scripts/docker-build.sh
```

## 📊 What Each Script Does

### validate.sh
```bash
✓ Checks Dockerfile exists
✓ Checks pom.xml exists
✓ Checks helm/ directory exists
✓ Checks buildspec.yml exists
✓ Verifies AWS_ACCOUNT_ID is set
✓ Verifies AWS_DEFAULT_REGION is set
```

### build.sh
```bash
✓ Runs: mvn clean package -DskipTests
✓ Outputs: target/lekka-service-0.0.1-SNAPSHOT.jar
```

### docker-build.sh
```bash
✓ Builds Docker image from Dockerfile
✓ Tags image with commit SHA
✓ Tags image as 'latest'
```

### ecr-push.sh
```bash
✓ Authenticates with ECR
✓ Pushes image with commit SHA tag
✓ Pushes image with 'latest' tag
```

### helm-deploy.sh
```bash
✓ Creates Kubernetes namespace
✓ Installs/upgrades Helm release
✓ Waits for deployment to be ready
✓ Reports service IP/hostname
```

### health-check.sh
```bash
✓ Verifies deployment is ready
✓ Checks all pods are running
✓ Verifies service is accessible
✓ Reports pod status
```

### rollback.sh
```bash
✓ Rolls back to previous Helm revision
✓ Waits for rollback to complete
✓ Verifies new deployment is healthy
```

## ⚙️ How to Use in CodeBuild

1. **Create CodeBuild Project** in AWS Console
2. **Set Source** to your GitHub repository
3. **Set Environment**:
   - Runtime: Ubuntu
   - Image: aws/codebuild/standard:7.0
   - Service Role: Create new
   
4. **Set BuildSpec**:
   - Source buildspec file: buildspec.yml
   
5. **Set Environment Variables**:
   - AWS_ACCOUNT_ID: Your account ID
   - AWS_DEFAULT_REGION: us-east-1

6. **CodeBuild will automatically**:
   - Execute buildspec.yml
   - Run all scripts in correct order
   - Push images to ECR
   - Deploy to EKS

## ✅ Checklist Before Deployment

- [ ] Dockerfile in project root
- [ ] pom.xml configured correctly
- [ ] helm/ directory with Chart.yaml and values.yaml
- [ ] buildspec.yml with correct AWS_ACCOUNT_ID and AWS_DEFAULT_REGION
- [ ] All scripts are executable (chmod +x)
- [ ] Scripts committed to Git
- [ ] EKS cluster is running
- [ ] ECR repository created
- [ ] GitHub webhook configured (for automatic triggers)

## 🐛 Troubleshooting

### If build fails
```bash
# Check CodeBuild logs
aws logs tail /aws/codebuild/lekka-service-build --follow
```

### If image push fails
```bash
# Verify ECR repository
aws ecr describe-repositories --repository-names lekka-service
```

### If deployment fails
```bash
# Check Kubernetes deployment
kubectl get deployments -n lekka-service
kubectl describe pod <pod-name> -n lekka-service
```

### If deployment times out
```bash
# Increase timeout in helm-deploy.sh
# Change: --timeout 5m to --timeout 10m
```

## 📚 File Locations

```
scripts/README.md          ← Detailed script documentation
buildspec.yml             ← CodeBuild configuration
helm/values.yaml          ← Kubernetes deployment config
Dockerfile               ← Docker image definition
pom.xml                  ← Maven project configuration
```

## 🎉 Done!

Your project now has:
✅ buildspec.yml for CodeBuild orchestration
✅ 9 executable scripts for each build phase
✅ Full documentation in scripts/README.md
✅ Production-ready pipeline configuration

**Next Steps:**
1. Configure CodeBuild project in AWS Console
2. Set up CodePipeline
3. Push code to GitHub
4. Watch automatic builds and deployments!

---

**For detailed script documentation, see: scripts/README.md**

