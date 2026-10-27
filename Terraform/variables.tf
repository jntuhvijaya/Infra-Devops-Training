variable "aws_region" {
  description = "AWS region for Terraform resources"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "terraform-practice-demo"
}