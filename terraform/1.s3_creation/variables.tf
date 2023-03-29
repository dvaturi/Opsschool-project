
variable "aws_region" {
  default = "us-east-2"
  type    = string
}

variable "owner_tag" {
  description = "The owner tag will be applied to every resource in the project through the 'default variables' feature"
  default = "dean-vaturi"
  type    = string
}

variable "purpose_tag" {
  default = "opsschool-project"
  type    = string
}

variable "created_by_tag" {
  default = "terraform"
  type    = string
}