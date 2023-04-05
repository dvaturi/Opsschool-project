output "consul-servers" {
  value = aws_instance.consul.*.public_dns
}
