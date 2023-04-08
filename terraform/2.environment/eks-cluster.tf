#Create EKS cluster
#module "eks" {
#  source          = "terraform-aws-modules/eks/aws"
#  cluster_name    = local.cluster_name
#  cluster_version = "1.17"
#  subnets         = module.vpc_module.private_subnet_ids

#  tags = {
#    Environment = "training"
#    GithubRepo  = "terraform-aws-eks"
#    GithubOrg   = "terraform-aws-modules"
#  }

#  vpc_id = module.vpc_module.vpc_id

#  worker_groups = [
#    {
#      name                          = "worker-group-1"
#      instance_type                 = "t2.small"
#      additional_userdata           = "echo foo bar"
#      asg_desired_capacity          = 2
#      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
#    },
#  ]
#}



#Creating Security Group
#resource "aws_security_group" "all_worker_mgmt" {
#  name = "eks-access"
#  description = "Allow all worker mgmt traffic"
#  vpc_id = module.vpc_module.vpc_id

#  tags = {
#    Name = "eks-wrkr-mgmt-${module.vpc_module.vpc_id}"
#    Owner = "Dean Vaturi"
#    Purpose = var.purpose_tag
#  }
#}

#resource "aws_security_group_rule" "allow_ssh" {
#  description       = "Allow SSH access from specified CIDR blocks"
#  from_port         = 22
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  to_port           = 22
#  type              = "ingress"
#  #need to change
#  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
#}

#resource "aws_security_group_rule" "prometheus1" {
#  description       = "prometheus"
#  from_port         = 9100
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  to_port           = 9100
#  type              = "ingress"
#  #need to change
#  cidr_blocks       = var.cidr_block
#}

#resource "aws_security_group_rule" "prometheus2" {
#  description       = "prometheus"
#  from_port         = 8500
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  to_port           = 8500
#  type              = "ingress"
#  #need to change
#  cidr_blocks       = var.cidr_block
#}

#resource "aws_security_group_rule" "allow_lan_tcp" {
#  description       = "Allow LAN TCP access to port 8301"
#  from_port         = 8301
#  to_port           = 8301
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
# type              = "ingress"
#  cidr_blocks       = var.cidr_block
#}

#resource "aws_security_group_rule" "allow_wan_tcp" {
#  description       = "Allow WAN TCP access to port 8302"
#  from_port         = 8302
#  to_port           = 8302
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
#}

#resource "aws_security_group_rule" "allow_lan_udp" {
#  description       = "Allow LAN UDP access to port 8301"
#  from_port         = 8301
#  to_port           = 8301
#  protocol          = "udp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
#}

#resource "aws_security_group_rule" "allow_wan_udp" {
#  description       = "Allow WAN UDP access to port 8302"
#  from_port         = 8302
#  to_port           = 8302
#  protocol          = "udp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
#}

#resource "aws_security_group_rule" "allow_consul_dns_tcp" {
#  description       = "Allow TCP access to Consul DNS on port 8600"
#  from_port         = 8600
#  to_port           = 8600
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
#}

#resource "aws_security_group_rule" "allow_consul_dns_udp" {
#  description       = "Allow UDP access to Consul DNS on port 8600"
#  from_port         = 8600
#  to_port           = 8600
#  protocol          = "udp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
#}
