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

**GitHub Secrets (Recommended):**
- Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to Repository Settings → Secrets

**Manual Input:**
- Use workflow dispatch with credentials as inputs

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

