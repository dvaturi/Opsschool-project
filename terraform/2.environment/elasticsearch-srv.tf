#Creating Elasticsearch and kibana servers instances
resource "aws_instance" "elasticsearch_server" {
  count = var.elasticsearch_server_count
  ami = data.aws_ami.ubuntu-18.id
  instance_type = var.instance_type2
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.elk_sg.id, aws_security_group.consul_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  subnet_id = element(module.vpc_module.private_subnets_id, count.index)
  user_data = "elasticsearch_kibana"
 
  tags = {
    Name = "elasticsearch-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
    consul_server = "false"
    elasticsearch_kibana = "true"
    kandula_app = "true"
  }
}

#Creating Security Group
resource "aws_security_group" "elk_sg" {
  name        = "Elk"
  description = "Security group for logging server"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name = "elk-server-access-${module.vpc_module.vpc_id}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}


resource "aws_security_group_rule" "elk_ssh_access" {
  description       = "allow ssh access from bastion"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.elk_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks = [for ip in data.aws_instance.bastion_private_ips.*.private_ip : "${ip}/32"]
}

resource "aws_security_group_rule" "elasticsearch_rest_access" {
  description       = "allow access to Elasticsearch REST API from"
  from_port         = 9200
  protocol          = "tcp"
  security_group_id = aws_security_group.elk_sg.id
  to_port           = 9200
  type              = "ingress"
  #need to change
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "elasticsearch_java_access" {
  description       = "allow access to Elasticsearch Java API from"
  from_port         = 9300
  protocol          = "tcp"
  security_group_id = aws_security_group.elk_sg.id
  to_port           = 9300
  type              = "ingress"
  #need to change
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "kibana_access" {
  description       = "allow access to Kibana from"
  from_port         = 5601
  protocol          = "tcp"
  security_group_id = aws_security_group.elk_sg.id
  to_port           = 5601
  type              = "ingress"
  #need to change
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "elk_logstash_access" {
  description       = "allow access to logstash from"
  from_port         = 5044
  protocol          = "tcp"
  security_group_id = aws_security_group.elk_sg.id
  to_port           = 5044
  type              = "ingress"
  #need to change
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "elk_https_access" {
  description       = "allow HTTPS access to "
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.elk_sg.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}

resource "aws_security_group_rule" "elk_logstash_monitoring_access" {
  description       = "allow access to Logstash monitoring from "
  from_port         = 9600
  protocol          = "tcp"
  security_group_id = aws_security_group.elk_sg.id
  to_port           = 9600
  type              = "ingress"
  cidr_blocks = var.internet_cidr
}


resource "aws_security_group_rule" "elk_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.elk_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = var.internet_cidr
} 
