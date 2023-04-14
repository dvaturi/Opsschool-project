terraform {
  backend "s3" {
    bucket = "opsschool-terraform-state-dean"
    key    = "opsschool/state/terraform.tfstate"
    region = "us-east-1"
  }
}
