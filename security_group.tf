resource "aws_security_group" "database_cluster" {
  name   = "fleet-db-cluster"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs_cluster.id}"]
  }
}

resource "aws_security_group" "ecs_alb" {
  name   = "fleet-ecs-alb"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ecs_alb_to_cluster" {
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.ecs_alb.id}"
  source_security_group_id = "${aws_security_group.ecs_cluster.id}"
  type                     = "egress"
}

resource "aws_security_group" "ecs_cluster" {
  name   = "fleet-ecs-cluster"
  vpc_id = "${var.vpc_id}"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs_alb.id}"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "redis_cluster" {
  name   = "fleet-redis-cluster"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs_cluster.id}"]
  }
}
