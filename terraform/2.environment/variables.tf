
variable "aws_region" {
  default = "us-east-2"
  type    = string
}

variable "source_pem_file_path" {
  default = "/home/ec2-user/.ssh/opsschoolproject.pem"
  type    = string
}

variable "destination_pem_file_path" {
  default = "/home/ubuntu/.ssh/opsschoolproject.pem"
  type    = string
}

variable "source_ansible_folder_path" {
  default = "/home/ec2-user/environment/.c9/opsschool9-dev-env/repositories/Opsschool-project/ansible"
  type    = string
}

variable "destination_ansible_folder_path" {
  default = "/home/ubuntu/ansible"
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

variable "consul_server_count" {
  description = "The number of consul server instances to create"
  default     = 3
}


variable "jenkins_master_instances_count" {
  description = "The number of jenkins server instances to create"
  default     = 1
}

variable "jenkins_slave_instances_count" {
  description = "The number of jenkins server instances to create"
  default     = 2
}


variable "internet_cidr" {
  type = list(string)
  default = [ "0.0.0.0/0"]
}

#need to change!!!!
variable "bastion_cidr_block_in" {
  type = list(string)
  default = [ "0.0.0.0/0"]
}


#need to change!!!!
variable "bastion_cidr_block" {
  type = list(string)
  default = [ "0.0.0.0/0", "0.0.0.0/0" ]
}

#need to change!!!!
variable "cidr_block" {
  type = list(string)
  default = [ "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0" ]
}

variable "kubernetes_version" {
  default = 1.18
  description = "kubernetes version"
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