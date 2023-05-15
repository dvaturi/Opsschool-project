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

data "http" "get_external_ip" {
  url = "https://api.ipify.org?format=text"
}

data "external" "parse_external_ip" {
  program = ["sh", "-c", "echo '{ \"ip\": \"'${data.http.get_external_ip.body}'\" }'"]
}


# Retrieve bastion instance private IPs
data "aws_instance" "bastion_private_ips" {
  count = var.bastion_instances_count
  instance_id = aws_instance.bastion[count.index].id
  depends_on = [aws_instance.bastion]
}

# Retrieve vpn instance public IPs
data "aws_instance" "vpn_public_ips" {
  count = var.vpn_instances_count
  instance_id = aws_instance.vpn[count.index].id
  depends_on = [aws_instance.vpn]
}

# Retrieve eks info
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}
