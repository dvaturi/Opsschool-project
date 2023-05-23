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
    consul_server = "false"
    # kandula_app = "true"
    eks_app = "true"
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
      min_size     = 1
      max_size     = 3
      desired_size = 1
      instance_types = ["t3.medium"]
    }

    group_2 = {
      min_size     = 1
      max_size     = 3
      desired_size = 1
      instance_types = ["t3.medium"]

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

resource "aws_security_group_rule" "ingress_cluster_443" {
  description       = "Cluster API to node groups"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "ingress_cluster_kubelet" {
  description       = "Cluster API to node kubelets"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "allow_ssh" {
 description       = "Allow SSH access from specified CIDR blocks"
 from_port         = 22
 protocol          = "tcp"
 security_group_id = aws_security_group.all_worker_mgmt_sg.id
 to_port           = 22
 type              = "ingress"
 cidr_blocks = [for ip in data.aws_instance.bastion_private_ips.*.private_ip : "${ip}/32"]
}

resource "aws_security_group_rule" "prometheus_tcp" {
  description       = "Allow Prometheus TCP access"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "prometheus_http" {
  description       = "Allow Prometheus HTTP access"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "lan_tcp" {
  description       = "Allow LAN TCP access"
  from_port         = 8301
  to_port           = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "wan_tcp" {
  description       = "Allow WAN TCP access"
  from_port         = 8302
  to_port           = 8302
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "lan_udp" {
  description       = "Allow LAN UDP access"
  from_port         = 8301
  to_port           = 8301
  protocol          = "udp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "rpc_tcp" {
  description       = "Allow LAN UDP access"
  from_port         = 8300
  to_port           = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "wan_udp" {
  description       = "Allow WAN UDP access"
  from_port         = 8302
  to_port           = 8302
  protocol          = "udp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "consul_dns_tcp1" {
  description       = "Allow Consul DNS TCP access"
  from_port         = 8600
  to_port           = 8600
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "consul_dns_udp1" {
  description       = "Allow Consul DNS UDP access"
  from_port         = 8600
  to_port           = 8600
  protocol          = "udp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "ingress_self_coredns_tcp" {
  description       = "Node to node CoreDNS"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  self        = true
}

resource "aws_security_group_rule" "ingress_self_coredns_udp" {
  description       = "Node to node CoreDNS"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  self        = true
}
 # metrics-server
resource "aws_security_group_rule" "ingress_cluster_4443_webhook" {
  description       = "Cluster API to node 4443/tcp webhook"
  from_port         = 4443
  to_port           = 4443
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}
# prometheus-adapter
resource "aws_security_group_rule" "ingress_cluster_6443_webhook" {
  description       = "Cluster API to node 6443/tcp webhook"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}
# Karpenter
resource "aws_security_group_rule" "ingress_cluster_8443_webhook" {
  description       = "Cluster API to node 8443/tcp webhook"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}
# ALB controller, NGINX
resource "aws_security_group_rule" "ingress_cluster_9443_webhook" {
  description       = "Cluster API to node 9443/tcp webhook"
  from_port         = 9443
  to_port           = 9443
  protocol          = "tcp"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}
resource "aws_security_group_rule" "eks_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.all_worker_mgmt_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = var.internet_cidr
}
resource "kubernetes_namespace" "kandula" {
  metadata {
    name = "kandula"
  }
}

resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

module "iam_iam-assumable-role-with-oidc" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.13.0"
  create_role                   = true
  role_name                     = "opsschool-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}


# Create the policy
resource "aws_iam_policy" "eks-cluster" {
  name        = "EKS-Node-Policy"
  path        = "/"
  description = "EKS Node Policy"
  policy      = file("${path.module}/templates/policies/eks-cluster.json")
}

# Attach the policy
resource "aws_iam_role_policy_attachment" "nodes-policy" {
  depends_on = [module.eks]
  for_each   = module.eks.eks_managed_node_groups
  role       = each.value.iam_role_name
  policy_arn = aws_iam_policy.eks-cluster.arn
}

resource "kubernetes_cluster_role_binding" "consul-sync-catalog-cluster-role-binding" {
  metadata {
    name = "consul-sync-catalog-rolebinding"

    annotations = {
      "kubectl.kubernetes.io/last-applied-configuration" = jsonencode({
        apiVersion: "rbac.authorization.k8s.io/v1",
        kind:       "ClusterRoleBinding",
        metadata: {
          annotations: {},
          name:        "consul-sync-catalog-rolebinding",
        },
        roleRef: {
          apiGroup: "rbac.authorization.k8s.io",
          kind:     "ClusterRole",
          name:     "view",
        },
        subjects: [
          {
            kind:      "ServiceAccount",
            name:      "consul-consul-sync-catalog",
            namespace: kubernetes_namespace.consul.metadata[0].name,
          },
        ],
      })
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "consul-consul-sync-catalog"
    namespace = kubernetes_namespace.consul.metadata[0].name
  }

  role_ref {
    kind     = "ClusterRole"
    name     = "view"
    api_group = "rbac.authorization.k8s.io"
  }
}
