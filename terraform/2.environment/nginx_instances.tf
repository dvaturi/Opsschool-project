#creating instance
#resource "aws_instance" "nginx" {
#  count                       = var.nginx_instances_count
#  ami                         = data.aws_ami.ubuntu-18.id
#  instance_type               = var.instance_type
#  key_name                    = var.key_name
#  associate_public_ip_address = true
#  subnet_id                   = module.vpc_module.public_subnets_id[count.index]
#  vpc_security_group_ids      = [aws_security_group.nginx_instances_access.id]
#  user_data                   = local.my-nginx-instance-userdata
#  iam_instance_profile        = aws_iam_instance_profile.nginx_instances.name

#  root_block_device {
#    encrypted   = false
#    volume_type = var.volumes_type
#    volume_size = var.nginx_root_disk_size
#  }

#  ebs_block_device {
#    encrypted   = true
#    device_name = var.nginx_encrypted_disk_device_name
#    volume_type = var.volumes_type
#    volume_size = var.nginx_encrypted_disk_size
#  }

#  tags = {
#    Name = "nginx-web-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
#    Owner = "Dean Vaturi"
#    Purpose = var.purpose_tag
#  }
#}

#creating Security group
#resource "aws_security_group" "nginx_instances_access" {
#  name            = "nginx-access"
#  description     = "allow standard and ssh ports inbound everything outbound"
#  vpc_id          = module.vpc_module.vpc_id

#  tags = {
#    Name = "nginx-access-${module.vpc_module.vpc_id}"
#    Owner = "Dean Vaturi"
#    Purpose = var.purpose_tag
#  }
#}

#resource "aws_security_group_rule" "nginx_http_access" {
#  description       = "allow http access from anywhere"
#  from_port         = 80
#  protocol          = "tcp"
#  security_group_id = aws_security_group.nginx_instances_access.id
#  to_port           = 80
#  type              = "ingress"
#  cidr_blocks       = ["0.0.0.0/0"]
#}

#resource "aws_security_group_rule" "nginx_ssh_access" {
#  description       = "allow ssh access from anywhere"
#  from_port         = 22
#  protocol          = "tcp"
#  security_group_id = aws_security_group.nginx_instances_access.id
#  to_port           = 22
#  type              = "ingress"
#  cidr_blocks       = ["0.0.0.0/0"]
#}

#resource "aws_security_group_rule" "nginx_outbound_anywhere" {
#  description       = "allow outbound traffic to anywhere"
#  from_port         = 0
#  protocol          = "-1"
#  security_group_id = aws_security_group.nginx_instances_access.id
#  to_port           = 0
#  type              = "egress"
#  cidr_blocks       = ["0.0.0.0/0"]
#}    
