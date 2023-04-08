#Creating bastion instances
resource "aws_instance" "bastion" {
  count = var.bastion_instances_count
  ami = data.aws_ami.ubuntu-18.id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = true
  subnet_id = element(module.vpc_module.public_subnets_id, count.index)
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  
  provisioner "file" {
    source      = "/home/ec2-user/.ssh/opsschoolproject.pem"
    destination = "/home/ubuntu/.ssh/opsschoolproject.pem"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/ec2-user/.ssh/opsschoolproject.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/.ssh/opsschoolproject.pem"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/ec2-user/.ssh/opsschoolproject.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "bastion-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
#    consul_server = "false"
#    kandula_app = "true"
  }
}

#Creating Security Group
resource "aws_security_group" "bastion_sg" {
  name = "bastion-access"
  description = "Allow ssh inbound traffic"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name = "bastion-access-${module.vpc_module.vpc_id}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_security_group_rule" "bastion_ssh_access" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = var.bastion_cidr_block_in
}

resource "aws_security_group_rule" "bastion_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.bastion_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = var.bastion_cidr_block_out
}