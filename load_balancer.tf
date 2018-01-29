resource "aws_alb" "ecs_alb" {
  name            = "fleet-service-alb"
  security_groups = ["${aws_security_group.ecs_alb.id}"]
  subnets         = ["${var.public_subnet_ids}"]
}

resource "aws_alb_listener" "ecs_alb" {
  certificate_arn    = "${var.acm_certificate_arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.ecs_alb.id}"
    type             = "forward"
  }
  load_balancer_arn  = "${aws_alb.ecs_alb.id}"
  port               = 443
  protocol           = "HTTPS"
  ssl_policy         = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

resource "aws_alb_target_group" "ecs_alb" {
  health_check {
    path = "/healthz"
  }
  name        = "fleet-service-alb-target-group"
  port        = "8080"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${var.vpc_id}"
}
