variable "env" {}
variable "subnet_id_private_web_a" {}
variable "subnet_id_private_web_c" {}
variable "logging_bucket" {}
variable "security_group_alb" {}
variable "vpc_id" {}


resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    var.security_group_alb
  ]
  subnets = [
    var.subnet_id_private_web_a,
    var.subnet_id_private_web_c
  ]
  # drop_invalid_header_fields = 
  enable_deletion_protection = false
  idle_timeout               = 60
  access_logs {
    bucket  = var.logging_bucket
    prefix  = "alb"
    enabled = true
  }
  tags = {
    Env = var.env
  }
}

resource "aws_lb_target_group" "web" {
  name                          = "web"
  port                          = 80
  protocol                      = "HTTP"
  deregistration_delay          = "300"
  slow_start                    = 0
  load_balancing_algorithm_type = "round_robin"
  target_type                   = "instance"
  vpc_id                        = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = false
  }

  health_check {
    enabled             = true
    interval            = 6
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  tags = {
    Env = var.env
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = ""

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_listener" "http_redirect_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
