#Creating consul servers instances
resource "aws_instance" "consul_server" {
  count = var.consul_server_count
  ami = data.aws_ami.ubuntu-18.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.consul_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  subnet_id = count.index == 2 ? element(module.vpc_module.private_subnets_id, 0) : element(module.vpc_module.private_subnets_id, count.index)

  tags = {
    Name = "consul-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
    consul_server = "true"
    kandula_app = "true"
  }
}

#Creating Security Group
resource "aws_security_group" "consul_sg" {
  name = "consul-access"
  description = "Allow ssh & consul inbound traffic"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name = "consul-server-access-${module.vpc_module.vpc_id}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_security_group_rule" "consul_allow_all_inside_security_group" {
  description       = "Allow all inside security group"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 0
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "consul_ssh_access" {
  description       = "allow ssh access from bastion"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks = [for ip in data.aws_instance.bastion_private_ips.*.private_ip : "${ip}/32"]
}

resource "aws_security_group_rule" "consul_rpc_tcp" {
  description       = "Server RPC address"
  from_port         = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8300
  type              = "ingress"
  cidr_blocks = var.consul_cidr_block
}

resource "aws_security_group_rule" "consul_lan_tcp" {
  description       = "The Serf LAN port"
  from_port         = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8301
  type              = "ingress"
  cidr_blocks = var.consul_cidr_block
}

resource "aws_security_group_rule" "consul_lan_udp" {
  description       = "The Serf LAN port"
  from_port         = 8301
  protocol          = "udp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8301
  type              = "ingress"
  cidr_blocks = var.consul_cidr_block
}

resource "aws_security_group_rule" "allow_consul_ui_access_from_world" {
  description       = "Allow consul UI access from the world"
  from_port         = 8500
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8500
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "consul_dns_tcp" {
  description       = "The DNS server"
  from_port         = 8600
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8600
  type              = "ingress"
  cidr_blocks = var.consul_cidr_block
}

resource "aws_security_group_rule" "consul_dns_udp" {
  description       = "The DNS server"
  from_port         = 8600
  protocol          = "udp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8600
  type              = "ingress"
  cidr_blocks = var.consul_cidr_block
}

resource "aws_security_group_rule" "consul_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = var.internet_cidr
} 


# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "consul-join"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "consul-join"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "consul-join"
  role = aws_iam_role.consul-join.name
}