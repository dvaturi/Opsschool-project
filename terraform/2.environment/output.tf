output "consul-servers" {
  value = aws_instance.consul_server.*.private_dns
}

output "bastion-servers" {
  value = aws_instance.bastion_server.*.public_dns
}
