# Terraform Backend Configuration
# This stores Terraform state remotely in S3 with DynamoDB locking

terraform {
  backend "s3" {
    # These will be provided via backend config
    # bucket         = "your-terraform-state-bucket"
    # key            = "lambda-service/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
  }
}
