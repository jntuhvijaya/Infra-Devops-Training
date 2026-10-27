resource "aws_s3_bucket" "practice" {
  bucket_prefix = "${var.bucket_prefix}-"

  force_destroy = false

  tags = {
    Name = "Terraform Practice Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "practice" {
  bucket = aws_s3_bucket.practice.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}