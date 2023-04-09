# Retrieve avaiable aws avilibility zones
data "aws_availability_zones" "available" {}

# Retrieve ubuntu server aws ami
data "aws_ami" "ubuntu-18" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
#retrive amazon linux 2 aws ami

 

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Retrieve bastion instance private IPs
data "aws_instance" "bastion_private_ips" {
  count = var.bastion_instances_count
  instance_id = aws_instance.bastion[count.index].id
  depends_on = [aws_instance.bastion]
}

#Retrieve eks info
#data "aws_eks_cluster" "cluster" {
#  name = module.eks.cluster_id
#}

#data "aws_eks_cluster_auth" "cluster" {
#  name = module.eks.cluster_id
#}

