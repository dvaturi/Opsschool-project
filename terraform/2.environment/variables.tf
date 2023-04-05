
variable "aws_region" {
  default = "us-east-2"
  type    = string
}

variable "instance_type" {
  description = "The type of the EC2, for example - t2.medium"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  default     = "opsschoolproject"
  description = "The key name of the Key Pair to use for the instance"
  type        = string
}

variable "ubuntu_account_number" {
  description = "The AWS account number of the offical Ubuntu Images"
  default     = "099720109477"
  type        = string
}

variable "bastion_instances_count" {
  description = "The number of bastion instances to create"
  default     = 2
}

variable "consul_instances_count" {
  description = "The number of consul server instances to create"
  default     = 3
}

variable "bastion_cidr_block" {
  type = list(string)
  default = [ "xxx.xxx.xxx.xxx/xx", "xxx.xxx.xxx.xxx/xx" ]
}

variable "cidr_block" {
  type = list(string)
  default = [ "xxx.xxx.xxx.xxx/xx", "xxx.xxx.xxx.xxx/xx", "xxx.xxx.xxx.xxx/xx", "xxx.xxx.xxx.xxx/xx", "xxx.xxx.xxx.xxx/xx" ]
}

#variable "nginx_instances_count" {
#  description = "The number of Nginx instances to create"
#  default     = 2
#}

#variable "DB_instances_count" {
#  description = "The number of DB instances to create"
#  default     = 2
#}

#variable "nginx_root_disk_size" {
#  description = "The size of the root disk"
#  default     = 10
#}

#variable "nginx_encrypted_disk_size" {
#  description = "The size of the secondary encrypted disk"
#  default     = 10
#}

#variable "nginx_encrypted_disk_device_name" {
#  description = "The name of the device of secondary encrypted disk"
#  default     = "xvdh"
#  type        = string
#}

#variable "volumes_type" {
#  description = "The type of all the disk instances in my project"
#  default     = "gp2"
#}

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