provider "aws" {
  profile = "default"
  region  = var.aws_region

#  default_tags {
#    tags = {
#        Owner = var.owner_tag
#        Purpose = var.purpose_tag
#        Created_by = var.created_by_tag
#    }
#  }
}