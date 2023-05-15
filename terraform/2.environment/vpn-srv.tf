#Creating vpn instances
resource "aws_instance" "vpn" {
  count = var.vpn_instances_count
  ami = data.aws_ami.ubuntu-18.id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = true
  subnet_id = element(module.vpc_module.public_subnets_id, count.index)
  vpc_security_group_ids = [aws_security_group.vpn_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.vpn.name
  depends_on = [aws_s3_bucket.opsschool_vpn_client]

  provisioner "file" {
    source      = var.source_vpn_script_path
    destination = var.destination_vpn_script_path
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.source_pem_file_path)
      host        = self.public_ip
    }
  }  

  provisioner "remote-exec" {
    inline = [
      "chmod +x openvpnsrv.sh",
      "sudo sh openvpnsrv.sh",
      "sudo apt-get update -y",
      "sudo apt-get install awscli -y",
      "aws s3 cp /home/ubuntu/opsschool.ovpn s3://opsschool-vpn-client/opsschool.ovpn"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.source_pem_file_path)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "vpn-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
    consul_server = "false"
    kandula_app = "false"
  }
}

resource "aws_s3_bucket" "opsschool_vpn_client" {
  bucket = "opsschool-vpn-client"
}

#Creating Security Group
resource "aws_security_group" "vpn_sg" {
  name = "vpn-access"
  description = "Allow ssh inbound traffic"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name = "vpn-access-${module.vpc_module.vpc_id}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_security_group_rule" "vpn_ssh_access" {
  description       = "allow ssh access from local machine"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.vpn_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["${data.external.parse_external_ip.result.ip}/32"]
}

resource "aws_security_group_rule" "vpn_access" {
  description       = "allow vpn access from local machine"
  from_port         = 1194
  protocol          = "udp"
  security_group_id = aws_security_group.vpn_sg.id
  to_port           = 1194
  type              = "ingress"
  cidr_blocks       = var.internet_cidr
}

resource "aws_security_group_rule" "vpn_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.vpn_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = var.internet_cidr
}

# Create an IAM role for vpn
resource "aws_iam_role" "vpn" {
  name               = "vpn"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "s3_manage" {
  name        = "s3_manage"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/s3-manage.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "vpn" {
  name       = "vpn"
  roles      = [aws_iam_role.vpn.name]
  policy_arn = aws_iam_policy.s3_manage.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "vpn" {
  name  = "vpn"
  role = aws_iam_role.vpn.name
}