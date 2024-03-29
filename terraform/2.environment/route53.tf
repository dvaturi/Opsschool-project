resource "aws_route53_zone" "opsschool-project" {
  name    = "opsschool-project.com"

  # vpc {
  #   vpc_id = module.vpc_module.vpc_id
  # }  
}

resource "aws_route53_record" "consul" {
  zone_id = aws_route53_zone.opsschool-project.zone_id
  name    = "consul.${aws_route53_zone.opsschool-project.name}" 
  # type    = "A"  
  type    = "CNAME"
  ttl     = "300"
  # records = ["${aws_instance.consul_server.private_ip}:${aws_lb_target_group.consul_server.port}"]
  records = ["${aws_lb.private_services.dns_name}:${aws_lb_target_group.consul_server.port}"]  
}

resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.opsschool-project.zone_id
  name    = "jenkins.${aws_route53_zone.opsschool-project.name}"
  # type    = "A"
  type    = "CNAME"
  ttl     = "300"
  # records = ["${aws_instance.jenkins_server.private_ip}:${aws_lb_target_group.jenkins_server.port}"]
  records = ["${aws_lb.private_services.dns_name}:${aws_lb_target_group.jenkins_server.port}"]
}

resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.opsschool-project.zone_id
  name    = "prometheus.${aws_route53_zone.opsschool-project.name}"
  # type    = "A"
  type    = "CNAME"
  ttl     = "300"
  # records = ["${aws_instance.prometheus_server.private_ip}:${aws_lb_target_group.prometheus_server.port}"]
  records = ["${aws_lb.private_services.dns_name}:${aws_lb_target_group.prometheus_server.port}"]
}

resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.opsschool-project.zone_id
  name    = "grafana.${aws_route53_zone.opsschool-project.name}"
  # type    = "A"
  type    = "CNAME"
  ttl     = "300"
  # records = ["${aws_instance.prometheus_server.private_ip}:${aws_lb_target_group.grafana_server.port}"]
  records = ["${aws_lb.private_services.dns_name}:${aws_lb_target_group.grafana_server.port}"]
}

resource "aws_route53_record" "kibana" {
  zone_id = aws_route53_zone.opsschool-project.zone_id
  name    = "kibana.${aws_route53_zone.opsschool-project.name}"
  # type    = "A"
  type    = "CNAME"
  ttl     = "300"
  # records = ["${aws_instance.elasticsearch_server.private_ip}:${aws_lb_target_group.kibana_server.port}"]
  records = ["${aws_lb.private_services.dns_name}:${aws_lb_target_group.kibana_server.port}"]
}