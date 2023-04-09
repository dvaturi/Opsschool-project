#Creating consul servers instances
resource "aws_instance" "consul_server" {
  count = var.consul_instances_count
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.consul_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  subnet_id = count.index == 2 ? element(module.vpc_module.private_subnets_id, 0) : element(module.vpc_module.private_subnets_id, count.index)
  
  user_data = <<EOF
              #!/bin/bash
              sudo yum install -y yum-utils shadow-utils
              sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              sudo yum -y install consul
              EOF


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

resource "aws_security_group_rule" "allow_http_from_world" {
  description       = "Allow http from the world"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 80
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_consul_ui_access_from_world" {
  description       = "Allow consul UI access from the world"
  from_port         = 8500
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8500
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_consul_ui_access_from_world2" {
  description       = "Allow consul UI access from the world"
  from_port         = 9100
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 9100
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lan_serf_tcp" {
  description       = "Lan Serf"
  from_port         = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8301
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "wan_self_tcp" {
  description       = "Wan self"
  from_port         = 8302
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8302
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lan_serf_udp" {
  description       = "Lan Serf"
  from_port         = 8301
  protocol          = "udp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8301
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_wan_udp_access" {
  description       = "Allow Consul WAN access via UDP"
  from_port         = 8302
  protocol          = "udp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8302
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_dns_tcp_access" {
  description       = "Allow Consul DNS access via TCP"
  from_port         = 8600
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8600
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_dns_udp_access" {
  description       = "Allow Consul DNS access via UDP"
  from_port         = 8600
  protocol          = "udp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8600
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "consul_server_tcp_access" {
  description       = "Allow Consul Server access via TCP"
  from_port         = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 8300
  type              = "ingress"
  #need to change
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "consul_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.consul_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
} 
