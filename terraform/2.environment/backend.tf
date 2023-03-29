terraform {
  backend "s3" {
    bucket = "opsschool-terraform-state"
    key    = "opsschool/state/terraform.tfstate"
    region = "us-east-2"
  }
}
