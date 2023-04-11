#Creating jenkins servers instances
resource "aws_instance" "jenkins_server" {
  count = var.jenkins_master_instances_count
  ami = data.aws_ami.ubuntu-18.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id, aws_security_group.consul_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  subnet_id = element(module.vpc_module.private_subnets_id, 0)
  user_data = "jenkins_master"

  tags = {
    Name = "jenkins-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
    consul_server = "false"
    jenkins = "true"
    kandula_app = "true"
  }
}

#Creating jenkins slaves instances
resource "aws_instance" "jenkins_slave" {
  count = var.jenkins_slave_instances_count
  ami = data.aws_ami.ubuntu-18.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id, aws_security_group.consul_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  subnet_id = element(module.vpc_module.private_subnets_id, count.index)
  user_data = "jenkins_slave"

  tags = {
    Name = "jenkins-slave-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
    consul_server = "false"
    jenkins = "true"
    kandula_app = "true"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name = "jenkins-access"
  description = "Allow ssh & jenkins inbound traffic"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name = "jenkins-server-access-${module.vpc_module.vpc_id}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_security_group_rule" "jenkins_https_access" {
  description       = "allow https from anywhere"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_sg.id
  to_port           = 443
  type              = "ingress"
  #need to change
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "jenkins_http_access" {
  description       = "allow http from anywhere"
  from_port         = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_sg.id
  to_port           = 8080
  type              = "ingress"
  #need to change
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "jenkins_ssh_access" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks = [for ip in data.aws_instance.bastion_private_ips.*.private_ip : "${ip}/32"]
}

resource "aws_security_group_rule" "jenkins_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.jenkins_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = var.internet_cidr
} 




