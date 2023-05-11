resource "aws_route53_zone" "opsschool_project" {
  name          = "opsschool_project.com"  
}

resource "aws_route53_record" "consul" {
  zone_id = aws_route53_zone.opsschool_project.zone_id
  name    = "consul.${aws_route53_zone.opsschool_project.name}"   
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.private_services.dns_name}:8500"]  
}

resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.opsschool_project.zone_id
  name    = "jenkins.${aws_route53_zone.opsschool_project.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.private_services.dns_name}:8080"]
}

resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.opsschool_project.zone_id
  name    = "prometheus.${aws_route53_zone.opsschool_project.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.private_services.dns_name}:9090"]
}

resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.opsschool_project.zone_id
  name    = "grafana.${aws_route53_zone.opsschool_project.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.private_services.dns_name}:3000"]
}

resource "aws_route53_record" "kibana" {
  zone_id = aws_route53_zone.opsschool_project.zone_id
  name    = "kibana.${aws_route53_zone.opsschool_project.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.private_services.dns_name}:5601"]
}
