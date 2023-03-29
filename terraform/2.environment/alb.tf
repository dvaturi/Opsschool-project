##creating alb load balancer
#resource "aws_lb" "web-nginx" {
#  name            = "nginx-alb-${module.vpc_module.vpc_id}"
#  internal        = false
#  load_balancer_type = "application"
#  subnets            = module.vpc_module.public_subnets_id
#  security_groups    = [aws_security_group.nginx_instances_access.id]

#  tags = {
#    Name = "nginx-alb-${module.vpc_module.vpc_id}"
#    Owner = "Dean Vaturi"
#    Purpose = var.purpose_tag
#  }
#}

#resource "aws_lb_listener" "web-nginx" {
#  load_balancer_arn = aws_lb.web-nginx.arn
#  protocol           = "HTTP"
#  port               = 80

#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.web-nginx.arn
#  }
#}

#resource "aws_lb_target_group" "web-nginx" {
#  name              = "nginx-target-group"
#  vpc_id            = module.vpc_module.vpc_id
#  port              = 80
#  protocol          = "HTTP"
#  stickiness {
#    type            = "lb_cookie"
#    cookie_duration = 60 # in seconds
#  }

#  health_check {
#    enabled = true
#    path    = "/"
#  }

#  tags = {
#    Name = "nginx-target-group-${module.vpc_module.vpc_id}"
#    Owner = "Dean Vaturi"
#    Purpose = var.purpose_tag
#  }
#}

#resource "aws_lb_target_group_attachment" "web_server" {
#  count           = length(aws_instance.nginx)
#  target_group_arn = aws_lb_target_group.web-nginx.id
#  target_id        = aws_instance.nginx.*.id[count.index]
#  port             = 80
#}