#Consul server
output "consul-servers" {
  value = aws_instance.consul_server.*.private_dns
}

# Bastion server
output "bastion_public_ips" {
  value = flatten([
    for instance in aws_instance.bastion : "ssh -i ~/.ssh/opsschoolproject.pem ubuntu@${instance.public_ip}"
  ])
}

# vpn server
output "vpn_public_ips" {
  value = flatten([
    for instance in aws_instance.vpn : "ssh -i ~/.ssh/opsschoolproject.pem ubuntu@${instance.public_ip}"
  ])
}

#EKS
output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "route53_records" {
  value = {
    consul     = aws_route53_record.consul.name
    jenkins    = aws_route53_record.jenkins.name
    prometheus = aws_route53_record.prometheus.name
    grafana    = aws_route53_record.grafana.name
    kibana     = aws_route53_record.kibana.name
  }
}



