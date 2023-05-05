#Creating promethus and grafana servers instances
resource "aws_instance" "prometheus_server" {
  count = var.prometheus_server_count
  ami = data.aws_ami.ubuntu-18.id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.prometheus_sg.id, aws_security_group.consul_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  subnet_id = element(module.vpc_module.private_subnets_id, count.index)
 
  tags = {
    Name = "promethus-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
    consul_server = "false"
    prometheus_server = "true"
    kandula_app = "true"
  }
}

#Creating Security Group
resource "aws_security_group" "prometheus_sg" {
  name        = "prometheus"
  description = "Security group for monitoring server"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name = "prometheus-server-access-${module.vpc_module.vpc_id}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_security_group_rule" "prometheus_allow_icmp_security_group" {
  description       = "Allow ICMP from control host IP"
  from_port         = 8
  protocol          = "icmp"
  security_group_id = aws_security_group.prometheus_sg.id
  to_port           = 0
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "prometheus_ssh_access" {
  description       = "allow ssh access from bastion"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks = [for ip in data.aws_instance.bastion_private_ips.*.private_ip : "${ip}/32"]
}

resource "aws_security_group_rule" "grafana_http_access" {
  description       = "allow http from anywhere"
  from_port         = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus_sg.id
  to_port           = 3000
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "prometheus_http_access" {
  description       = "allow http from anywhere"
  from_port         = 9090
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus_sg.id
  to_port           = 9090
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "prometheus_grafana_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.prometheus_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = var.internet_cidr
} 
