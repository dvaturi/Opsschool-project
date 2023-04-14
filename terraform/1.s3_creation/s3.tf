provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "opsschool-terraform-state-dean"
  tags = {
    Owner = var.owner_tag
    Purpose = var.purpose_tag
    Created_by = var.created_by_tag
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
