resource "aws_lb" "private_services" {
  name               = "privateservices"
  internal           = false
  load_balancer_type = "application"
  #security_groups    = [aws_security_group.prometheus_grafana.id, aws_security_group.consul_sg.id]
  security_groups    = [aws_security_group.consul_sg.id]
  subnets            = module.vpc_module.public_subnets_id

  tags = {
    Environment = "production"
  }
}

# ### listener rule - prometheus

# resource "aws_lb_target_group" "Prometheus" {
#   name        = "Prometheus"
#   port        = 9090
#   protocol    = "HTTP"
#   target_type = "instance"
#   vpc_id      = module.vpc.vpc_id
  
#   health_check {
#     port     = 9090
#     protocol = "HTTP"
#   }
# }

# resource "aws_lb_target_group_attachment" "Prometheus" {
#   count = var.promethus_count 
#   target_group_arn = aws_lb_target_group.Prometheus.arn
#   target_id        = aws_instance.promethus_server[count.index].id
#   port             = 9090
# }

# resource "aws_lb_listener" "Prometheus" {
#   load_balancer_arn = aws_lb.private_services.arn
#   port              = "9090"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.Prometheus.arn
#   }
# }



# ### listener rule - grafana
# resource "aws_lb_target_group" "Grafana" {
#   name        = "Grafana"
#   port        = 3000
#   protocol    = "HTTP"
#   target_type = "instance"
#   vpc_id      = module.vpc.vpc_id
  
#   health_check {
#     port     = 3000
#     protocol = "HTTP"
#   }
# }

# resource "aws_lb_target_group_attachment" "Grafana" {
#   count = var.promethus_count 
#   target_group_arn = aws_lb_target_group.Grafana.arn
#   target_id        = aws_instance.promethus_server[count.index].id
#   port             = 3000
# }

# resource "aws_lb_listener" "Grafana" {
#   load_balancer_arn = aws_lb.private_services.arn
#   port              = "3000"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.Grafana.arn
#   }
# }


# ### listener rule - kibana
# resource "aws_lb_target_group" "Kibana" {
#   name        = "Kibana"
#   port        = 5601
#   protocol    = "HTTP"
#   target_type = "instance"
#   vpc_id      = module.vpc.vpc_id
  
#   health_check {
#     port     = 5601
#     protocol = "HTTP"
#   }
# }

# resource "aws_lb_target_group_attachment" "Kibana" {
#   count = var.elasticsearch_instance_count 
#   target_group_arn = aws_lb_target_group.Kibana.arn
#   target_id        = aws_instance.elasticsearch_kibana[count.index].id
#   port             = 5601
# }

# resource "aws_lb_listener" "Kibana" {
#   load_balancer_arn = aws_lb.private_services.arn
#   port              = "5601"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.Kibana.arn
#   }
# }


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
  }
}

resource "aws_lb_target_group_attachment" "consul_server" {
  count = var.consul_instances_count 
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
resource "aws_lb_target_group" "jenkins" {
  name        = "jenkins"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id = module.vpc_module.vpc_id
  
  health_check {
    port     = 8080
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "jenkins" {
  count = var.jenkins_master_instances_count 
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = aws_instance.jenkins_server[count.index].id
  port             = 8080
}

resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = aws_lb.private_services.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}




