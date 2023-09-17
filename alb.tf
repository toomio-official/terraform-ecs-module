resource "aws_alb" "application_load_balancer" {
  name               = local.project_name
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets

  security_groups = [aws_security_group.load_balancer_security_group.id]
}

resource "aws_lb_target_group" "toomio_backend_target_group" {
  name        = "toomio-backend-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    matcher = "200"
    path    = "/health"
  }
}


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
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

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.toomio_backend_target_group.arn
  }
}

resource "aws_lb_listener_rule" "toomio_backend_listener_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  condition {
    host_header {
      values = ["api.toomio.com"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.toomio_backend_target_group.arn
  }
}
