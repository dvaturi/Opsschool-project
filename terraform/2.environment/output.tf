output "consul-servers" {
  value = aws_instance.consul.*.private_dns
}
