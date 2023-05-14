
variable "aws_region" {
  default = "us-east-1"
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

variable "source_vpn_script_path" {
  default = "/home/ec2-user/environment/.c9/opsschool9-dev-env/repositories/Opsschool-project/terraform/2.environment/scripts/openvpnsrv.sh"
  type    = string
}

variable "destination_vpn_script_path" {
  default = "/home/ubuntu/openvpnsrv.sh"
  type    = string
}

variable "instance_type" {
  description = "The type of the EC2, for example - t2.medium"
  type        = string
  default     = "t2.micro"
}

variable "instance_type2" {
  description = "The type of the EC2, for example - t2.medium"
  type        = string
  default     = "m4.large"
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
  description = "The number of jenkins slave instances to create"
  default     = 2
}

variable "prometheus_server_count" {
  description = "The number of prometheus and grafana server instances to create"
  default = 1
}

variable "elasticsearch_server_count" {
  description = "The number of elasticsearch server instances to create"
  default = 1
}

variable "vpn_instances_count" {
  description = "The number of vpn instances to create"
  default     = 1
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
variable "consul_cidr_block" {
  type = list(string)
  default =  [ "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16" ]
}

variable "kubernetes_version" {
  default = 1.24
  description = "kubernetes version"
}

locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "opsschool-sa"
  cluster_name = "opsschool-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
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