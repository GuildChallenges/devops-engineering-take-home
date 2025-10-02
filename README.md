# Guild Lambda Service - Standardized Deployment Pattern

A production-ready deployment pattern for AWS Lambda with IaC, CI/CD, and operational best practices.

## Deployment Status

**SUCCESSFULLY DEPLOYED AND TESTED**

- **Environment**: Development (`dev`)
- **AWS Region**: `us-east-1`
- **API Endpoint**: `https://{your-api-id}.execute-api.us-east-1.amazonaws.com/dev/hello`
- **Lambda Function**: `guild-dev-hello-service-v2-function`
- **Resources Created**: 24 AWS resources
- **Status**: Working and tested successfully

## Testing the Service

### API Endpoint Testing

**Endpoint**: `https://{your-api-id}.execute-api.us-east-1.amazonaws.com/dev/hello`

**Test with curl:**
```bash
curl -X POST "https://{your-api-id}.execute-api.us-east-1.amazonaws.com/dev/hello" \
  -H "Content-Type: application/json" \
  -d '{"name": "DevOps Engineer"}'
```

**Test without name:**
```bash
curl -X POST "https://{your-api-id}.execute-api.us-east-1.amazonaws.com/dev/hello" \
  -H "Content-Type: application/json"
```

**Example with actual endpoint:**
```bash
curl -X POST "https://xm9pb9b9bl.execute-api.us-east-1.amazonaws.com/dev/hello" \
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

**Response without name:**
```json
{
  "message": "Hello from dev!",
  "environment": "dev",
  "version": "1.0.0",
  "request_id": "abc123-def456"
}
```

**Note**: This API only accepts POST requests. Browser testing will show "Missing Authentication Token" because browsers make GET requests by default. Use curl or a REST client for testing.

### Monitoring and Logs

- **CloudWatch Logs**: `/aws/lambda/guild-dev-hello-service-v2-function`
- **AWS Console**: Lambda → Functions → `guild-dev-hello-service-v2-function`
- **Response Time**: ~1 second (normal for cold start)
- **HTTP Status**: 200 OK

### Getting Your API Endpoint

After deployment, you can get your API endpoint in several ways:

**Option 1: From GitHub Actions Logs**
1. Go to your repository's Actions tab
2. Click on the latest deployment workflow
3. Look for the "Run integration tests" step
4. The API endpoint will be displayed in the logs

**Option 2: From AWS Console**
1. Go to AWS API Gateway console
2. Find your API: `guild-dev-hello-service-v2-lambda-api`
3. Click on "Stages" → "dev"
4. Copy the "Invoke URL"

**Option 3: From Terraform Output**
```bash
cd iac/environments/dev
terraform output api_gateway_url
```

**Option 4: From AWS CLI**
```bash
aws apigateway get-rest-apis --query 'items[?name==`guild-dev-hello-service-v2-lambda-api`].id' --output text
# Then use: https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/hello
```

### Monitoring & Observability

- **CloudWatch Logs**: `/aws/lambda/guild-dev-hello-service-v2-function`
- **CloudWatch Dashboard**: Available in AWS Console
- **X-Ray Tracing**: Enabled for request tracing
- **Dead Letter Queue**: Configured for error handling

## Quick Start - Deploy to Your AWS Account

Anyone can deploy this to their own AWS account:

### Prerequisites
- AWS Account with appropriate permissions
- GitHub repository (fork this repo)
- AWS credentials (Access Key ID and Secret Access Key)

### Deployment Steps

1. **Fork this repository** to your GitHub account
2. **Set up AWS credentials** in GitHub Secrets:
   - Go to Repository Settings → Secrets and variables → Actions
   - Add these secrets:
     - `AWS_ACCESS_KEY_ID`: Your AWS access key
     - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
3. **Trigger deployment**:
   - Push to `feat/ekene/interview/exercise` branch (development)
   - Or push to `main` branch (production)
   - Or use "Run workflow" button in Actions tab
4. **Get your API endpoint** using the methods above
5. **Test your deployment** with curl

### Cleanup Infrastructure

To destroy all created resources:

1. **Go to Actions tab** in your repository
2. **Click "Deploy Lambda Service"** workflow
3. **Click "Run workflow"** button
4. **Select "destroy"** as the action
5. **Select environment** to destroy (dev/staging/prod)
6. **Click "Run workflow"**
7. **Manual approval required** - GitHub will ask for confirmation
8. **Confirm destruction** - All AWS resources will be deleted

**Warning**: This will permanently delete all infrastructure including:
- Lambda function and API Gateway
- IAM roles and policies  
- CloudWatch logs and alarms
- SQS dead letter queue
- KMS keys and SSM parameters

### Customization

You can customize the deployment by:
- **Changing project name**: Update `project_name` in workflow inputs
- **Changing service name**: Update `service_name` in workflow inputs  
- **Changing AWS region**: Update `aws_region` in workflow inputs
- **Adding environments**: Extend the workflow for staging/production

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

## Implemented Features

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

