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

# Retrieve bastion instance private IPs
data "aws_instance" "bastion_private_ips" {
  count = var.bastion_instances_count
  instance_id = aws_instance.bastion[count.index].id
  depends_on = [aws_instance.bastion]
}