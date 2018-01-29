variable "acm_certificate_arn" {}

variable "auth_jwt_key" {}

variable "aws_region" {}
variable "aws_zones" {
  type = "list"
}

variable "db_password" {}
variable "db_subnet_group_name" {}

variable "docker_image" {}

variable "elasticache_subnet_group_name" {}

variable "private_subnet_ids" {
  type = "list"
}
variable "public_subnet_ids" {
  type = "list"
}

variable "vpc_id" {}
