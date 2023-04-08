#aws
provider "aws" {
  profile = "default"
  region  = var.aws_region

#  default_tags {
#    tags = {
#        Owner = var.owner_tag
#        Purpose = var.purpose_tag
#        Created_by = var.created_by_tag
#    }
#  }
}


#kubernetis 
#provider "kubernetes" {
#  load_config_file       = "false"
#  host                   = data.aws_eks_cluster.cluster.endpoint
#  token                  = data.aws_eks_cluster_auth.cluster.token
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#}