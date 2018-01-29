resource "aws_db_instance" "fleet_db" {
  allocated_storage       = "8"
  backup_retention_period = "1"
  db_subnet_group_name    = "${var.db_subnet_group_name}"
  engine                  = "mariadb"
  identifier              = "fleet-db"
  instance_class          = "db.t2.micro"
  multi_az                = true
  name                    = "fleet"
  option_group_name       = "default:mariadb-10-2"
  parameter_group_name    = "default.mariadb10.2"
  password                = "${var.db_password}"
  skip_final_snapshot     = true
  username                = "fleet"
  vpc_security_group_ids  = ["${aws_security_group.database_cluster.id}"]
}
