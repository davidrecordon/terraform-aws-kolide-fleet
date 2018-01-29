 data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

data "template_file" "ecs_fleet_task_definition_file" {
  template = "${file("${path.module}/task-definitions/fleet_task.json")}"

  vars {
    aws_region            = "${var.aws_region}"
    image                 = "${var.docker_image}"
    KOLIDE_AUTH_JWT_KEY   = "${var.auth_jwt_key}"
    KOLIDE_MYSQL_ADDRESS  = "${join(":", list(aws_db_instance.fleet_db.address, aws_db_instance.fleet_db.port))}"
    KOLIDE_MYSQL_DATABASE = "${aws_db_instance.fleet_db.name}"
    KOLIDE_MYSQL_PASSWORD = "${aws_db_instance.fleet_db.password}"
    KOLIDE_MYSQL_USERNAME = "${aws_db_instance.fleet_db.username}"
    KOLIDE_REDIS_ADDRESS  = "${aws_elasticache_replication_group.redis.configuration_endpoint_address}"
  }
}
