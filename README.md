# Guild Lambda Service - Standardized Deployment Pattern

A production-ready deployment pattern for AWS Lambda with IaC, CI/CD, and operational best practices.

## 🚀 Deployment Status

**✅ SUCCESSFULLY DEPLOYED!**

- **Environment**: Development (`dev`)
- **AWS Region**: `us-east-1`
- **API Endpoint**: `https://ibk5vp56e4.execute-api.us-east-1.amazonaws.com/dev/hello`
- **Resources Created**: 24 AWS resources
- **Status**: Ready for testing and production use

## 🧪 Testing the Service

### API Endpoint Testing

**Endpoint**: `https://ibk5vp56e4.execute-api.us-east-1.amazonaws.com/dev/hello`

**Test with curl:**
```bash
curl -X POST "https://ibk5vp56e4.execute-api.us-east-1.amazonaws.com/dev/hello" \
  -H "Content-Type: application/json" \
  -d '{"name": "DevOps Engineer"}'
```

**Expected Response:**
```json
{
  "message": "Hello from dev! Welcome, DevOps Engineer!",
  "environment": "dev",
  "version": "1.0.0",
  "request_id": "abc123-def456"
}
```

### Monitoring & Observability

- **CloudWatch Logs**: `/aws/lambda/guild-dev-hello-service-*`
- **CloudWatch Dashboard**: Available in AWS Console
- **X-Ray Tracing**: Enabled for request tracing
- **Dead Letter Queue**: Configured for error handling

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

## ✅ Implemented Features

### Core Infrastructure
- **AWS Lambda Function** with Python 3.11 runtime
- **API Gateway** with HTTP endpoint (`/hello`)
- **Infrastructure as Code** using modular Terraform
- **GitHub Actions CI/CD** with automated testing and deployment

### Security & Compliance
- **KMS Encryption** for data at rest
- **IAM Least Privilege** with scoped permissions
- **Dead Letter Queue** for error handling
- **Security Scanning** with bandit and safety

### Monitoring & Observability
- **CloudWatch Logs** with structured JSON logging
- **CloudWatch Alarms** for error rates and latency
- **CloudWatch Dashboard** for operational visibility
- **X-Ray Tracing** for request tracing
- **SSM Parameter Store** for configuration management

### Operational Excellence
- **Automated Backend Setup** (S3 + DynamoDB)
- **Environment-specific Deployments**
- **Comprehensive Testing** (unit, integration, security)
- **Modular Architecture** for reusability

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

