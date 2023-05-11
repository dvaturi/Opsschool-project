resource "aws_lb" "private_services" {
  name               = "privateservices"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.consul_sg.id, aws_security_group.jenkins_sg.id, aws_security_group.prometheus_sg.id , aws_security_group.elk_sg.id ]
  subnets            = module.vpc_module.public_subnets_id

  tags = {
    Environment = "production"
  }
}


### listener rule - consul 
resource "aws_lb_target_group" "consul_server" {
  name        = "consul"
  port        = 8500
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id = module.vpc_module.vpc_id
  
  health_check {
    port     = 8500
    protocol = "HTTP"
    path     = "/v1/agent/self"
  }
}

resource "aws_lb_target_group_attachment" "consul_server" {
  count = var.consul_server_count 
  target_group_arn = aws_lb_target_group.consul_server.arn
  target_id        = aws_instance.consul_server[count.index].id
  port             = 8500
}

resource "aws_lb_listener" "consul_server" {
  load_balancer_arn = aws_lb.private_services.arn
  port              = "8500"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_server.arn
  }
}

### listener rule - jenkins
resource "aws_lb_target_group" "jenkins_server" {
  name        = "jenkins"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id = module.vpc_module.vpc_id
  
  health_check {
    port     = 8080
    protocol = "HTTP"
    path     = "/login?from=%2F"
  }
}

resource "aws_lb_target_group_attachment" "jenkins_server" {
  count = var.jenkins_master_instances_count 
  target_group_arn = aws_lb_target_group.jenkins_server.arn
  target_id        = aws_instance.jenkins_server[count.index].id
  port             = 8080
}

resource "aws_lb_listener" "jenkins_server" {
  load_balancer_arn = aws_lb.private_services.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_server.arn
  }
}

### listener rule - Prometheus

resource "aws_lb_target_group" "prometheus_server" {
  name        = "Prometheus"
  port        = 9090
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id = module.vpc_module.vpc_id
  
  health_check {
    port     = 9090
    protocol = "HTTP"
    path     = "/-/healthy"
  }
}

resource "aws_lb_target_group_attachment" "prometheus_server" {
  count = var.prometheus_server_count
  target_group_arn = aws_lb_target_group.prometheus_server.arn
  target_id        = aws_instance.prometheus_server[count.index].id
  port             = 9090
}

resource "aws_lb_listener" "prometheus_server" {
  load_balancer_arn = aws_lb.private_services.arn
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_server.arn
  }
}

### listener rule - Grafana

resource "aws_lb_target_group" "grafana_server" {
  name        = "Grafana"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id = module.vpc_module.vpc_id
  
  health_check {
    port     = 3000
    protocol = "HTTP"
    path     = "/-/healthy"
  }
}

resource "aws_lb_target_group_attachment" "grafana_server" {
  count = var.prometheus_server_count
  target_group_arn = aws_lb_target_group.grafana_server.arn
  target_id        = aws_instance.prometheus_server[count.index].id
  port             = 3000
}

resource "aws_lb_listener" "grafana_server" {
  load_balancer_arn = aws_lb.private_services.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_server.arn
  }
}

### listener rule - Kibana

resource "aws_lb_target_group" "kibana_server" {
  name        = "Kibana"
  port        = 5601
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id = module.vpc_module.vpc_id
  
  health_check {
    port     = 5601
    protocol = "HTTP"
    # path     = "/-/healthy"
  }
}

resource "aws_lb_target_group_attachment" "kibana_server" {
  count = var.elasticsearch_server_count
  target_group_arn = aws_lb_target_group.kibana_server.arn
  target_id        = aws_instance.elasticsearch_server[count.index].id
  port             = 5601
}

resource "aws_lb_listener" "kibana_server" {
  load_balancer_arn = aws_lb.private_services.arn
  port              = "5601"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana_server.arn
  }
}

