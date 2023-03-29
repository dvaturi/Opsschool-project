#variable "bastion_server" {
#  default = 1
#}
#resource "aws_instance" "bastion" {
#    count = var.bastion_server
#    ami = lookup(var.ami, var.region)
#    instance_type = "t2.micro"
#    key_name = var.key_name
#    subnet_id = element(module.vpc.public_subnet_ids, count.index )
#    associate_public_ip_address = true
#    iam_instance_profile   = aws_iam_instance_profile.consul-join.name
#    vpc_security_group_ids = [aws_security_group.bastion_kandula.id]
    
#    tags = {
#    Name = "bastion-kandula-${count.index+1}"
#    consul_server = "false"
#    kandula_app = "true"
#  }
#}

#resource "aws_security_group" "bastion_kandula" {
#  name = "bastion-kandula"
#  description = "Allow ssh inbound traffic"
#  vpc_id = module.vpc_module.vpc_id

#  ingress {
#    from_port = 22
#    to_port = 22
#    protocol = "tcp"
#    cidr_blocks = var.cidr_block
#  }

#  egress {
#    description = "Allow all outgoing traffic"
#    from_port = 0
#    to_port = 0
#    // -1 means all
#    protocol = "-1"
#    cidr_blocks = [
#      "0.0.0.0/0"
#    ]
#  }
#  tags = {
#    Name = "bastion-sg-kandula"
#    consul_server = "false"
#    kandula_app = "true"
#  }
#}
