# Internal ALB(frontend-app -> internal ALB)
resource "aws_lb" "internal" {
  name               = "sbcntr-alb-internal"
  load_balancer_type = "application"
  internal           = true

  security_groups = [
    aws_security_group.sbcntr_sg_internal.id
  ]

  subnets = [
    aws_subnet.sbcntr_subnet_private_container1["a"].id,
    aws_subnet.sbcntr_subnet_private_container1["c"].id,
  ]
}

# 🔍
resource "aws_lb_listener" "debug_internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "20080"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}

resource "aws_lb_target_group" "internal_blue" {
  name     = "sbcntr-tg-sbcntrdemo-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.sbcntr_vpc.id

  health_check {
    interval            = 15
    path                = "/healthcheck"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_lb_listener" "internal_blue" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_blue.arn
  }
}

resource "aws_lb_target_group" "internal_green" {
  name     = "sbcntr-tg-sbcntrdemo-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.sbcntr_vpc.id

  health_check {
    interval            = 15
    path                = "/healthcheck"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_lb_listener" "internal_green" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "10080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_green.arn
  }
}
