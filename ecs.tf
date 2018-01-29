resource "aws_ecs_cluster" "fleet_cluster" {
  name = "fleet-cluster"
}

resource "aws_ecs_task_definition" "fleet_task" {
  container_definitions    = "${data.template_file.ecs_fleet_task_definition_file.rendered}"
  cpu                      = 256
  depends_on               = ["aws_iam_role_policy.ecs_task_execution_role_policy"]
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
  family                   = "fleet-server"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "fleet_service" {
  cluster       = "${aws_ecs_cluster.fleet_cluster.id}"
  depends_on    = ["aws_alb_listener.ecs_alb",]
  desired_count = 1
  launch_type   = "FARGATE"
  load_balancer {
    container_name   = "fleet-server"
    container_port   = 8080
    target_group_arn = "${aws_alb_target_group.ecs_alb.id}"
  }
  name            = "fleet-service"
  network_configuration {
      subnets         = ["${var.private_subnet_ids}"]
      security_groups = ["${aws_security_group.ecs_cluster.id}"]
  }
  task_definition = "${aws_ecs_task_definition.fleet_task.arn}"
}

resource "random_id" "code" {
  byte_length = 4
}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "ecsTaskExecutionRolePolicy-${random_id.code.hex}"
  role   = "${aws_iam_role.ecs_task_execution_role.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole-${random_id.code.hex}"
  assume_role_policy = <<EOF
{
 "Version": "2008-10-17",
 "Statement": [
   {
     "Sid": "",
     "Effect": "Allow",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Action": "sts:AssumeRole"
   }
 ]
}
EOF
}
