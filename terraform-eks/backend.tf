# This is a placeholder - update with your actual backend configuration
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  # For S3 backend (recommended for team use):
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "terraform-eks/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}