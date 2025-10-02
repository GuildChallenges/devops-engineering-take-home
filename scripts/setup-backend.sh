#!/bin/bash

# Setup Terraform Backend Infrastructure
# This script creates S3 bucket and DynamoDB table for Terraform state

set -e

# Configuration
BUCKET_NAME="${1:-guild-terraform-state-$(date +%s)}"
REGION="${2:-us-east-1}"
DYNAMODB_TABLE="${3:-terraform-state-lock}"

echo "Setting up Terraform backend..."
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "DynamoDB Table: $DYNAMODB_TABLE"

# Create S3 bucket for Terraform state
echo "Creating S3 bucket: $BUCKET_NAME"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Enable versioning on the bucket
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
echo "Enabling server-side encryption..."
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create DynamoDB table for state locking
echo "Creating DynamoDB table: $DYNAMODB_TABLE"
aws dynamodb create-table \
  --table-name $DYNAMODB_TABLE \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region $REGION

# Wait for table to be active
echo "Waiting for DynamoDB table to be active..."
aws dynamodb wait table-exists --table-name $DYNAMODB_TABLE --region $REGION

echo "Backend setup complete!"
echo ""
echo "Add these GitHub Secrets:"
echo "TERRAFORM_STATE_BUCKET=$BUCKET_NAME"
echo "TERRAFORM_STATE_REGION=$REGION"
echo "TERRAFORM_STATE_DYNAMODB_TABLE=$DYNAMODB_TABLE"
echo ""
echo "Or use these values in your workflow:"
echo "bucket: $BUCKET_NAME"
echo "region: $REGION"
echo "dynamodb_table: $DYNAMODB_TABLE"
