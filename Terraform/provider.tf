provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "terraform-practice"
      Environment = "learning"
      ManagedBy   = "Terraform"
    }
  }
}