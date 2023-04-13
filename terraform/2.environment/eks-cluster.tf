#Create EKS cluster
module "eks" {
 source          = "terraform-aws-modules/eks/aws"
 version         = "19.10.0"
 cluster_name    = local.cluster_name
 cluster_version = var.kubernetes_version
 subnet_ids      = module.vpc_module.private_subnets_id
 cluster_endpoint_private_access = false
 cluster_endpoint_public_access = true

 enable_irsa = true

 tags = {
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
    # consul_server = "false"
    # kandula_app = "true"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
 }

vpc_id  = module.vpc_module.vpc_id

eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["t3.medium"]
      vpc_security_group_ids = [aws_security_group.all_worker_mgmt_sg.id]
      key_name               = var.key_name
}

eks_managed_node_groups = {
    
    group_1 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.medium"]
    }

    group_2 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.large"]

    }
  }
}



#Creating Security Group
resource "aws_security_group" "all_worker_mgmt_sg" {
 name_prefix = "all_worker_management"
 description = "Allow all worker mgmt traffic"
 vpc_id = module.vpc_module.vpc_id

 tags = {
   Name = "eks-wrkr-mgmt-${module.vpc_module.vpc_id}"
   Owner = "Dean Vaturi"
   Purpose = var.purpose_tag
 }
}

resource "aws_security_group_rule" "allow_ssh" {
 description       = "Allow SSH access from specified CIDR blocks"
 from_port         = 22
 protocol          = "tcp"
 security_group_id = aws_security_group.all_worker_mgmt_sg.id
 to_port           = 22
 type              = "ingress"
 cidr_blocks = [for ip in data.aws_instance.bastion_private_ips.*.private_ip : "${ip}/32"]
#  cidr_blocks = [ "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16" ]
}


# resource "aws_security_group_rule" "allow_lan_tcp" {
#  description       = "Allow LAN TCP access to port 8301"
#  from_port         = 8301
#  to_port           = 8301
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
# type              = "ingress"
#  cidr_blocks       = var.cidr_block
# }

# resource "aws_security_group_rule" "allow_wan_tcp" {
#  description       = "Allow WAN TCP access to port 8302"
#  from_port         = 8302
#  to_port           = 8302
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
# }

# resource "aws_security_group_rule" "allow_lan_udp" {
#  description       = "Allow LAN UDP access to port 8301"
#  from_port         = 8301
#  to_port           = 8301
#  protocol          = "udp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
# }

# resource "aws_security_group_rule" "allow_wan_udp" {
#  description       = "Allow WAN UDP access to port 8302"
#  from_port         = 8302
#  to_port           = 8302
#  protocol          = "udp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
# }

# resource "aws_security_group_rule" "allow_consul_dns_tcp" {
#  description       = "Allow TCP access to Consul DNS on port 8600"
#  from_port         = 8600
#  to_port           = 8600
#  protocol          = "tcp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
# }

# resource "aws_security_group_rule" "allow_consul_dns_udp" {
#  description       = "Allow UDP access to Consul DNS on port 8600"
#  from_port         = 8600
#  to_port           = 8600
#  protocol          = "udp"
#  security_group_id = aws_security_group.all_worker_mgmt.id
#  type              = "ingress"
#  cidr_blocks       = var.cidr_block
# }


module "iam_iam-assumable-role-with-oidc" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.13.0"
  create_role                   = true
  role_name                     = "opsschool-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}
