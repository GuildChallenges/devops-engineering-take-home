# Guild Lambda Service - Standardized Deployment Pattern

A production-ready deployment pattern for AWS Lambda with IaC, CI/CD, and operational best practices.

## Development Workflow

### Branch Strategy
- **Feature Branch**: `feat/ekene/interview/exercise` - Development deployment
- **Main Branch**: `main` - Production deployment
- **Pull Requests**: Run tests only (no deployment)

### Pipeline Triggers
- **Push to `feat/ekene/interview/exercise`** → Deploy to development
- **Push to `main`** → Deploy to production  
- **Pull Request to `main`** → Run tests only
- **Manual trigger** → Deploy to any environment

### CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Code Quality**
   - Linting with flake8
   - Type checking with mypy
   - Code formatting with black

2. **Security Scanning**
   - Dependency vulnerability scanning
   - Static code analysis with bandit

3. **Testing**
   - Unit tests with pytest
   - Coverage reporting
   - Integration tests

4. **Deployment**
   - Environment-specific deployments
   - Infrastructure validation
   - Post-deployment health checks

### AWS Credentials Setup

**GitHub Secrets (Required for deployment):**
1. Go to Repository Settings → Secrets and variables → Actions
2. Add these secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `TERRAFORM_STATE_BUCKET`: S3 bucket for Terraform state (run setup script first)
   - `TERRAFORM_STATE_DYNAMODB_TABLE`: DynamoDB table for state locking

**Default Configuration:**
- **AWS Region**: `us-east-1`
- **Environment**: `dev`
- **Project**: `guild`
- **Service**: `hello-service`

**Terraform State Management:**
- **Remote State**: S3 bucket with DynamoDB locking
- **State Persistence**: Infrastructure state survives between deployments
- **Concurrent Safety**: DynamoDB prevents concurrent modifications
- **Automatic Setup**: Backend infrastructure created automatically during deployment

**Manual Input (for manual deployment):**
- Use workflow dispatch with credentials as inputs
- Go to Actions → Deploy Lambda Service → Run workflow

**IAM Role:**
- Use OIDC authentication with AWS IAM roles

## Features

- AWS Lambda with HTTP endpoint via API Gateway
- Infrastructure as Code using Terraform (modular design)
- GitHub Actions CI/CD pipeline
- CloudWatch monitoring, alarms, and dashboards
- SSM Parameter Store for configuration
- KMS encryption, DLQ, X-Ray tracing
- Provisioned concurrency with auto-scaling
- Security scanning and comprehensive testing

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │───▶│  Lambda Function│───▶│  SSM Parameters │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       ▼                       │
         │              ┌─────────────────┐              │
         │              │  CloudWatch     │              │
         │              │  Logs & Metrics │              │
         │              └─────────────────┘              │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Monitoring    │    │   Dead Letter    │    │   KMS Encryption│
│   & Alerting    │    │      Queue       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Project Structure

```
├── src/                    # Application code
├── iac/                    # Infrastructure as Code
│   ├── modules/           # Reusable Terraform modules
│   └── environments/dev/  # Development environment
└── .github/workflows/     # CI/CD Pipeline
```

