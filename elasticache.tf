resource "aws_elasticache_replication_group" "redis" {
  automatic_failover_enabled    = true
  cluster_mode {
    num_node_groups         = "${length(var.aws_zones)}"
    replicas_per_node_group = 0
  }
  engine                        = "redis"
  node_type                     = "cache.t2.small"
  parameter_group_name          = "default.redis3.2.cluster.on"
  port                          = 6379
  replication_group_description = "Redis cluster for Fleet"
  replication_group_id          = "fleet-redis-cluster"
  security_group_ids            = ["${aws_security_group.redis_cluster.id}"]
  snapshot_retention_limit      = 1
  subnet_group_name             = "${var.elasticache_subnet_group_name}"
}
